$:.unshift(File.expand_path(File.dirname(__FILE__)))

begin
  require 'facets'
  require 'facets/date'
rescue
  require 'rubygems'
  require 'facets'
  require 'facets/date'
end

require 'date'

require 'core_ext/string'
require 'calendar_maker/view_helpers'
require 'calendar_maker/calendar'
