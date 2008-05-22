$:.unshift(File.expand_path(File.dirname(__FILE__)))

begin
  require 'facets'
rescue
  require 'rubygems'
  require 'facets'
end

require 'date'
require 'calendar_maker/string_extensions'
require 'calendar_maker/view_helpers'
require 'calendar_maker/calendar'
