class Folder
  attr_accessor :name, :projects, :column

  def initialize(name, project=nil)
    @name = name
    @projects = []
    self << project if project
  end

  def display_name
    if Options.has_key? "separator"
      @name.gsub("|",Options["separator"])
    else
      @name
    end
  end

  def css_classes
    if @projects.all?(&:background?)
      "background"
    else
      ""
    end
  end

  def << project
    @projects << project
    project.folder = self
  end

  def sorted_projects
    projects.sort_by{ |p| p.background? ? 1 : 0 }
  end

  # The colour of all projects contained within this folder
  def colour
    column.board.colour_for_folder(self.name)
  end

  # Is this folder expanded? Determined by the column
  def expanded?
    column.expanded?
  end

  # Does this folder consider a given project as "background"?
  def considers_background?(project)
    column.considers_background?(project)
  end
end