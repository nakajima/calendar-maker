module StringHelpers
  
  # Borrowed from Facets gem
  def indent(n)
    if n >= 0
      gsub(/^/, ' ' * n)
    else
      gsub(/^ {0,#{-n}}/, "")
    end
  end
  
  def tab(n)
    gsub(/^ */, ' ' * n)
  end
  
  def tabto(n)
    if self =~ /^( *)\S/
      indent(n - $1.length)
    else
      self
    end
  end
  
  def then_add(string)
    self << "\n#{string}"
  end
  
  def truncate(length = 30, truncate_string = "...")
    l = length - truncate_string.length
    self.length > length ? self[0...l] + truncate_string : self
  end
  
end

String.send :include, StringHelpers