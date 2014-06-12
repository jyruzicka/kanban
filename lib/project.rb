# Each project square in the kanban is represented by an instance of this class.
class Project
  # The project's name
  attr_accessor :name

  # The project's status as string ("On hold", "Done", "Active", "Dropped", "Task Deferred", "Project Deferred")
  attr_accessor :status

  # The number of days until this project becomes active again
  attr_accessor :days_deferred

  # OmniFocus ID
  attr_accessor :id

  # Array of folders that contain this project
  attr_accessor :ancestors

  # The number of remaining tasks in this project
  attr_accessor :num_tasks

  @projects = []
  class << self
    # Array of all projects
    attr_accessor :projects

    # Add this project to the global database.
    # @param p [Project] The project to add to the database.
    def add p
      @projects << p
    end

    # Remove all projects from the database
    def purge
      @projects = []
    end

    # Returns array all projects.
    # Same as calling +Project.projects+.
    def all
      @projects
    end

    # Return all projects which fulfil a given condition
    # @param blck [Proc] filter proc.
    # @return [Array] all projects for which +blck[p]+ returns true.
    def select &blck
      @projects.select(&blck)
    end

    # Loads the database from file.
    def load
      Project.purge
      database = SQLite3::Database.new(Options.database_location)
      database.results_as_hash = true
      database.execute("SELECT * FROM projects").each do |row|
        ## Custom actions
        # Defer date
        defer_date = row["deferredDate"]
        defer_date = (defer_date > 0 && Time.at(defer_date))
        days_deferred = defer_date && (defer_date.to_date - Date.today).to_i

        # Status
        status = row["status"]
        if status == "Deferred"
          if row["deferralType"] == "task"
            status = "Task deferred"
          else
            status = "Project deferred"
          end
        end
          
        p = Project.new(
          name:           row["name"],
          status:         status,
          days_deferred:  days_deferred,
          id:             row["ofid"],
          num_tasks:      row["numberOfTasks"]
        )
        p.ancestors_string = row["ancestors"]
      end
    end
  end

  # Standard initializer
  # @param name [String] the name of the project
  # @param status [String] the project's status (see #status)
  # @param days_deferred [int] the number of days until this project is active again
  # @param id [String] the OmniFocus ID of the project
  # @param num_tasks [int] the number of remaining tasks this project contains
  def initialize(name:"",status:"", days_deferred:-1, id:nil, num_tasks:1)
    self.name = name
    self.status = status
    self.days_deferred = days_deferred
    self.id = id
    self.num_tasks = num_tasks
    Project.add(self)
  end

  # Can this project be hidden?
  # Applies to any project which is "active" but cannot be acted on right now
  # e.g. deferred, waiting on, hanginging
  def hideable?
    @hideable ||= ["Task deferred", "Project deferred", "Waiting on", "Hanging"].include?(status)
  end

  # Is this project deferred?
  def deferred?
    @deferred ||= (status.end_with?("deferred") || status.end_with?("Deferred"))
  end

  # Set the ancestors array from a pipe-delimited string
  # @param str [String] A pipe-delimited string of ancestor names
  def ancestors_string= str
    @ancestors = str.split("|")
  end

  # Outputs a string of ancestors, separated by the html Right arrow character
  def ancestors_string
    @ancestors.join(" &rarr; ")
  end

  # A space-separated list of classes to add to the project's corresponding html
  # element.
  def css_class
    @css_class ||= ["project", status.gsub(' ','-').downcase, (hideable? ? "hideable" : nil)].compact.join(" ")
  end

  # The board this project should be displayed on.
  def board
    @board ||= if Options.backburner_filter.include?(@status)
      :backburner
    elsif Options.completed_filter.include?(@status)
      :completed
    else
      :active
    end
  end
end