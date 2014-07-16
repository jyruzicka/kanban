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
    begin
      Options.ensure_config_exists!
      
      projects = Project.load_from_database
      @board = Board.new(projects)

      haml :index
    rescue KanbanError => e
      @error = e
      haml :error
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
