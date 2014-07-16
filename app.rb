# Kanban-fetch V1.0.2
#
# By Jan-Yves Ruzicka
# For more information:
# http://1klb.com/projects/kanban-fetch
# or see the readme

require "sinatra"
require "sass"
require "haml"
require "sqlite3"
require "date"

Dir['./lib/*.rb'].each{ |f| require f }

class Kanban < Sinatra::Base
  # Index!
  get '/' do
    # Error check
    if !File.exists?(Options.config_file)
      @reason = "Cannot locate config file."
      @fix = "Ensure `config.yaml` exists. You may wish to rename `config.yaml.sample`."
    else
      # This is all our data, grabbed from SQLIte
      projects = Project.load_from_database
      @board = Board.new
      @board.add_projects(projects)
      
    #   Project.load
    #   if Project.error?
    #     @reason = "Cannot locate database: `#{Options.database_location}`."
    #     @fix = "Edit `database_location` in `config.yaml`. Are you sure you have it pointed at the right location?"
    #   end
    # end

    # if @reason
    #   haml :error
    # else
    #   # @projects contains all the projects we want to display
    #   # It's divided up into the three columns of the kanban board:
    #   # :backburner, :active and :completed
    #   #
    #   # Each of these boards is then divided up based on ancestry
    #   @projects = Project.grouped_by_board_and_ancestry

    #   # @size measures the number of projects on each board
    #   boards = [:active, :backburner, :completed]
    #   @size = boards.each_with_object({}){ |board, hsh| hsh[board] = Project.select{ |p| p.board == board }.size }
    #   @size[:running] = Project.select{ |p| p.status == "Active"}.count
      
    #   # Auto-colour projects
    #   ancestries = @projects.values.map{ |h| h.keys }.flatten.uniq #Array of every ancestry
    #   @colours = ColourMap.new(ancestries).to_hash
      
      haml :index
    end
  end

  get '/refresh' do
    system(Options.binary_location, *Options.binary_options)
    redirect to '/'
  end

  get '/styles.css' do
    scss :styles
  end
end
