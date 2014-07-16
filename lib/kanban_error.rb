class KanbanError < Exception
  attr_accessor :reason, :fix
  def initialize(reason:"", fix:"")
    @reason = reason
    @fix = fix
  end
end