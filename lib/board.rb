# Represents the board as a whole
class Board
  attr_accessor :columns

  def initialize(projects)
    @columns = []
    populate_columns
    add_projects(projects) if projects
  end

  # Populates columns based on YAML data (config file)
  def populate_columns
    raw_column_data = Options.fetch_or_fail("columns")

    raw_column_data.each do |raw_column|
      column = Column.from_hash raw_column
      column.board = self
      @columns << column
    end
  end

  # Add an array of projects. Each project is added to the
  # correct column
  def add_projects projects
    projects.each do |project|
      applicable_column = @columns.find{ |c| c.matches?(project) }
      applicable_column << project if applicable_column
    end
  end

  # Determine the correct colour for a given folder name
  # Will stay constant as long as no folders are added or removed
  def colour_for_folder folder_name
    folder_names = columns.map(&:folders).flatten.map(&:name).flatten.uniq.sort
    increment = (folder_names.empty? ? 0 : 360 / folder_names.size)
    idx = folder_names.index(folder_name)
    return "hsl(#{increment*idx},100%,80%)"
  end
end