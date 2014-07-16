helpers do
  def count(column)
    ap = column.active_projects
    str = "("
    str << if column.limit && ap > column.limit
      %|<span class="danger">#{ap}</span>|
    else
      ap
    end
    str << "|#{column.total_projects}" if ap != column.total_projects
    str << ")"
    str
  end
end