$:.unshift(File.expand_path(File.dirname(__FILE__)))

begin
  require 'activesupport'
rescue LoadError
  require 'rubygems'
  retry
end

require 'date'
require 'core_ext/string'
require 'calendar_maker/view_helpers'
require 'calendar_maker/calendar'
