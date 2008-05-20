class Calendar
  include ViewHelpers

  # <tt>month</tt> <Integer>:: the month for the calendar
  # <tt>year</tt> <Integer>:: the year for the calendar
  # <tt>days</tt> <Hash>:: the days for the calendar, including scheduled events
  # <tt>events</tt> <Array>:: the events for this calendar
  attr_reader :month, :year, :days, :events

  def initialize(options={})
    @month    = options[:month]  || Time.now.month
    @year     = options[:year]   || Time.now.year
    @page     = Time.utc(@year, @month)
    @days     = Hash.new
    @events   = options[:events] || []
    self.date = Date.new(@page.year, @page.month)

    days_in_month.times { |i| @days[i] = { :events => [] } }
  end

  alias_method :day, :days
  
  # The week day number the calendar starts on
  def starts_on
    date.wday
  end
  
  # The week day number the calendar ends on
  def ends_on
    (date + days_in_month - 1).wday
  end
  
  # Adds some events to the calendar
  #
  # ==== Parameters
  # +event_objects+ <Array>:: 
  #   a list of objects with dates relating to this calendar
  # +options+ <Hash>::
  #   a Hash of options to configure the events added
  # 
  # ===== Options
  # <tt>:schedule_for</tt>:: 
  #   the method you can call on the event objects to get the date of their 
  #   event
  # <tt>:html_class</tt>::
  #   see <tt>:schedule_for</tt>
  def add(event_objects, options={})
    raise ArgumentError, "Must specify :schedule_for attribute to assign events to days." unless options[:schedule_for]
    options[:html_class] ||= options[:schedule_for]
    event_objects.each do |event|
      schedule_for = event.send(options[:schedule_for])
      if schedule_for && schedule_for.month == month && schedule_for.year == year
        @events << options[:html_class] unless @events.include?(options[:html_class])
        @days[schedule_for.day][:events] << options[:html_class]
      end
    end
  end
  
  # Renders an instance to an HTML table
  #
  # ==== Parameters
  # +options+ <Hash>::
  #   a Hash of options. See Options below for further details
  #
  # ===== Options
  # <tt>:header_length</tt> <Integer>::
  #   the length of the string to use for month names
  # <tt>:ignore_today</tt> <true,false>::
  #   whether or not to give today's date a CSS class
  #
  # ==== Returns
  # String
  def generate(options={})
    options[:header_length] ||= 1
    options[:ignore_today]  ||= false
    build(options) # see ViewHelpers
  end

  alias_method :to_html, :generate
  
  # Borrowed from active_support
  def days_in_month
    if @page.month == 2
      !@page.year.nil? && (@page.year % 4 == 0) && ((@page.year % 100 != 0) || (@page.year % 400 == 0)) ?  29 : 28
    elsif @page.month <= 7
      @page.month % 2 == 0 ? 30 : 31
    else
      @page.month % 2 == 0 ? 31 : 30
    end
  end

  private

    # <tt>:date</tt> <Date>:: used internally for date manipulations
    attr_accessor :date
  
end
