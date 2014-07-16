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

  # The parent folder
  attr_accessor :folder

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

    # Return projects, grouped by board and then by ancestry
    # Active projects are also sorted according to active status
    def grouped_by_board_and_ancestry
      @grouped_ba ||= begin
        h = Project.all.group_by(&:board).each_with_object({}) do |(board, projects),hash|
          hash[board] = projects.group_by(&:ancestors_string) unless board.nil?
        end

        # We would like to sort active projects
        h[:active].each do |ancestry, project_list|
          h[:active][ancestry] = project_list.sort_by{ |p| p.status == "Active" ? 0 : 1 }
        end
        h
      end
    end

    # An error occured on loading
    def error!
      @error = true
    end

    # Did an error occur on loading?
    def error?
      @error
    end

    # Loads the database from file.
    def load_from_database
      if File.exists?(Options.database_location)
        projects = []
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
          projects << p
        end
        projects
      else
        error!
      end
    end

    def load
      Project.purge
      
      if !File.exists?(Options.database_location)
        error!
        return
      end

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

  alias_method :folder_name, :ancestors_string

  # A space-separated list of classes to add to the project's corresponding html
  # element.
  def css_class
    @css_class ||= begin
      classes = ["project"]
      classes << status.gsub(' ','-').downcase
      classes << "expanded" if expanded?
      classes << "background" if background?
      classes.join(" ")
    end
  end

  # Colour is determined by the folder containing the project
  def colour
    if folder
      folder.colour
    else
      "#333"
    end
  end

  # Is the project expanded? Determined by its folder
  def expanded?
    folder ? folder.expanded? : false
  end

  # Is this project background?
  def background?
    folder ? folder.considers_background?(self) : false
  end

  def active?
    !background?
  end

  # The column this project should be displayed on.
  def column
    @column ||= if Options.backburner_filter.include?(@status)
      :backburner
    elsif Options.completed_filter.include?(@status)
      :completed
    elsif Options.hidden_filter.include?(@status)
      nil
    else
      :active
    end
  end
end