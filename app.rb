require "sinatra"
require "sass"
require "haml"
require "sqlite3"
require "date"

Dir['./lib/*.rb'].each{ |f| require f }

class Kanban < Sinatra::Base
  # Index!
  get '/' do

    # This is all our data, grabbed from SQLIte
    Project.load

    # @projects contains all the projects we want to display
    # It's divided up into the three columns of the kanban board:
    # :backburner, :active and :completed
    #
    # Each of these boards is then divided up based on ancestry...
    @projects = {}

    Project.all.group_by(&:board).each do |board, projects|
      @projects[board] = projects.group_by(&:ancestors_string)
    end
    
    # We would like to sort active projects
    @projects[:active].each do |ancestry, project_list|
      @projects[:active][ancestry] = project_list.sort_by{ |p| p.status == "Active" ? 0 : 1 }
    end

    # @size measures the number of projects on each board
    boards = [:active, :backburner, :completed]
    @size = boards.each_with_object({}){ |board, hsh| hsh[board] = Project.select{ |p| p.board == board }.size }
    @size[:running] = Project.select{ |p| p.status == "Active"}.count
    
    # Auto-colour projects
    lineages = @projects.values.map{ |h| h.keys }.flatten.uniq
    @colours = {}
    increment = lineages.empty? ? 0 : 360 / lineages.size

    lineages.each_with_index do |lin, i|
     @colours[lin] = "hsl(#{increment*i},100%,80%)"
    end

    haml :index
  end

  get '/refresh' do
    # Replace with whatever script you use to refresh your data
    `#{ENV['HOME']}/bin/kanban-fetch`
    redirect to '/'
  end

  get '/styles.css' do
    scss :styles
  end
end
