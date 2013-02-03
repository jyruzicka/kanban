require "sinatra"
require "haml"
require "sass"
require "jcache"
require 'date'

Dir['lib/*.rb'].each{ |f| require f }

class Kanban < Sinatra::Base
  # Index!
  get '/' do

    # This is all our data
    cache = JCache::Cache.new('pkfetch')[:data]


    cache.each do |p|
      # For each event in here, let's now set a deferred-until value
      # if it's deferred.
      p[:days_until] = (p[:deferred_until].to_date - Date.today).to_i if p[:kanban_status] == :deferred
    end

    # Data for viewing
    @projects = {}
    @size = {}

    {
      done: [:done],
      backburner: [:backburner],
      wip: [:wip, :deferred, :waiting_on, :hanging]
    }.each do |key, statuses|
      buffer = cache.select{ |pj| statuses.include? pj[:kanban_status] }
      @size[key] = buffer.size
      
      # Special wip-only thing to account for multiple statuses
      if key == :wip
        @size[:true_wip] = cache.select{ |pj| pj[:kanban_status] == :wip }.size
      end
      
      @projects[key] = buffer.group_by{ |pj| pj[:ancestors].join('&rarr;') }
    end

    # wip-only task-sorting
    @projects[:wip].keys.each do |k|
      @projects[:wip][k] = @projects[:wip][k].sort_by{ |p| p[:kanban_status] == :wip ? 0 : 1 }
    end

    lineages = @projects.values.map{ |h| h.keys }.flatten.uniq
    @colours = {}
    increment = lineages.empty? ? 0 : 360 / lineages.size

    lineages.each_with_index do |lin, i|
      @colours[lin] = "hsl(#{increment*i},100%,80%)"
    end

    haml :index
  end

  get '/refresh' do
    `/Users/jan/Programs/ruby/organised/pkfetch/pkfetch -f`
    redirect to '/'
  end

  get '/styles.css' do
    scss :styles
  end
end