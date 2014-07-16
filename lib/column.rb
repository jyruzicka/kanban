# Represents one column in the board

class Column
  attr_accessor :name, :width,
                :include, :background,
                :expanded, :limit,
                :folders, :board

  def self.from_hash(hash)
    column = Column.new(hash["name"])
    column.width = hash["width"] || 1
    column.include = hash["include"]
    column.background = hash["background"] || []
    column.expanded = hash["expanded"] || false
    column.limit = hash["limit"] || nil
    column
  end

  def initialize(name)
    @name = name
    @include = []
    @background = []
    @folders = []
  end

  # Does this project match the column?
  def matches?(project)
    @include.include?(project.status) ||
    @background.include?(project.status)
  end

  # Add a project
  def << project
    folder = @folders.find{ |f| f.name == project.folder_name }
    if folder
      folder << project
    else
      f = Folder.new(project.folder_name, project)
      f.column = self
      @folders << f
    end
  end

  # Is this column expanded?
  def expanded?
    expanded
  end

  # Counter
  def active_projects
    folders.map(&:projects).flatten.select(&:active?).size
  end

  def total_projects
    folders.map(&:projects).flatten.size
  end

  # Does this column consider a particular project "background"?
  def considers_background?(project)
    @background.include?(project.status)
  end

  # HTML-ised count
  def count
    ap = active_projects
    str = "("
    str << ((limit && ap > limit) ? %|<span class="danger">#{ap}</span>| : ap.to_s)
    str << "|#{total_projects}" if ap != total_projects
    str << ")"
    str
  end
end