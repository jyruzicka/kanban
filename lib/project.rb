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

  # Containing folder string (from database)
  attr_accessor :folder_name

  # The number of remaining tasks in this project
  attr_accessor :num_tasks

  # The parent folder
  attr_accessor :folder

  class << self
    # Loads the database from file.
    def load_from_database
      if !File.exists?(Options.database_location)
        raise KanbanError,
              reason: "Cannot find database at `#{Options.database_location}`",
              fix:    "Make sure `config.yaml`'s value `database_location` is pointed at your database."
      end

      projects = []
      database = SQLite3::Database.new(Options.database_location)
      database.results_as_hash = true
      database.execute("SELECT * FROM projects").each do |row|
        projects << Project.from_sqlite(row)
      end
      projects
    end

    def from_sqlite(row)
      p = Project.new(
        name: row["name"],
        id: row["ofid"],
        num_tasks: row["numberOfTasks"],
        folder_name: row["ancestors"]
      )

      p.status = if row["status"] == "Deferred"
        row["deferralType"] == "task" ? "Task deferred" : "Project deferred"
      elsif row["status"] == "Active" && row["numberOfTasks"] == 0
        "Hanging"
      else
        row["status"]
      end

      p.days_deferred = if row["deferredDate"] > 0
        (Time.at(row["deferredDate"]).to_date - Date.today).to_i
      else
        nil
      end

      p
    end
  end

  # Standard initializer
  # @param name [String] the name of the project
  # @param status [String] the project's status (see #status)
  # @param days_deferred [int] the number of days until this project is active again
  # @param id [String] the OmniFocus ID of the project
  # @param num_tasks [int] the number of remaining tasks this project contains
  def initialize(name:"",status:"", days_deferred:-1, id:nil, num_tasks:1,folder_name:"")
    self.name = name
    self.status = status
    self.days_deferred = days_deferred
    self.id = id
    self.num_tasks = num_tasks
    self.folder_name = folder_name
  end

  # Is this project deferred?
  def deferred?
    @deferred ||= (status.end_with?("deferred") || status.end_with?("Deferred"))
  end

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
end