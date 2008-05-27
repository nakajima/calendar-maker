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
    @days     = Hash.new
    @events   = options[:events] || []

    # Used incase the user specifies a string-based month. E.g. 'oct'.
    page      = Time.utc(@year, @month)
    self.date = Date.new(page.year, page.month)

    date.days_of_month.each { |i| @days[i] = { :events => [] } }
  end

  alias_method :day, :days
  
  # The week day number the calendar starts on
  def starts_on
    date.wday
  end
  
  # The week day number the calendar ends on
  def ends_on
    Date.new(year, month, -1).wday
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
    raise ArgumentError, "Must specify :schedule_for attribute to assign events to days" unless options[:schedule_for]
    options[:html_class] ||= options[:schedule_for]
    event_objects.each do |event|
      schedule_for = event.send(options[:schedule_for])
      if event_okay?(schedule_for)
        events << options[:html_class] unless events.include?(options[:html_class])
        days[schedule_for.day][:events] << options[:html_class]
      end
    end
  end

  private

  # <tt>:date</tt> <Date>:: used internally for date manipulations
  attr_accessor :date

  # Checks some Date or Time object to see if it is the currently considered 
  # Date or Time.
  #
  # ==== Parameters
  # +schedule_for+ <~month, ~year>:: the event being examined
  def event_okay?(schedule_for)
    schedule_for && 
      schedule_for.month == month && 
      schedule_for.year  == year
  end
  
end
