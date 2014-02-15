class Project
  attr_accessor :name, :status, :days_deferred, :id,:ancestors, :num_tasks

  class << self
    attr_accessor :projects
  end

  def initialize(name:"",status:"", days_deferred:-1, id:nil, num_tasks:1)
    @name = name
    @status = status
    @days_deferred = days_deferred
    @id = id
    @num_tasks = num_tasks
    Project.add(self)
  end

  def ancestors_string= str
    @ancestors = str.split("|")
  end

  def ancestors_string
    @ancestors.join(" &rarr; ")
  end

  def css_class
    @css_class ||= "project #{status.gsub(' ','-').downcase}"
  end

  def board
    @board ||= if @status == "Backburner"
      :backburner
    elsif @status == "Completed"
      :completed
    else
      :active
    end
  end

  @projects = []

  def self.add p
    @projects << p
  end

  def self.purge
    @projects = []
  end

  def self.all
    @projects
  end

  def self.select &blck
    @projects.select(&blck)
  end

  def self.load
    Project.purge
    database = SQLite3::Database.new(File.join(ENV["HOME"], ".kb/test.db"))
    database.results_as_hash = true
    database.type_translation = true
    database.execute("SELECT * FROM projects").each do |row|
      p = Project.new(
        name:           row["name"],
        status:         row["status"],
        days_deferred:  row["daysdeferred"],
        id:             row["ofid"],
        num_tasks:      row["num_tasks"]
      )
      p.ancestors_string = row["ancestors"]
    end
  end
end