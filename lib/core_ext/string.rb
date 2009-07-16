class String
  def tab(spaces=2)
    ' ' * spaces + self
  end

  def then_add(string)
    self << "\n#{string}"
  end
end
