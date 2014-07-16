class ColourMap
  def initialize(array_of_options)
    @options = array_of_options    
  end

  def to_hash
    increment = @options.empty? ? 0 : 360 / @options.size
    r_hash = {}
    @options.each_with_index{ |opt, i| r_hash[opt] = "hsl(#{increment*i},100%,80%)" }
    r_hash
  end
end