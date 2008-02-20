class Calendar
  include ViewHelpers
  
  def initialize(options={})
    options[:month] ||= Time.now.month
    options[:year]  ||= Time.now.year
    @events = options[:events] || []
    @page   = Time.utc(options[:year], options[:month])
    @days   = { }; days_in_month.times { |i| @days[i] = { :events => [] } }
  end
  
  def month; @page.month; end
  
  def year;  @page.year;  end
  
  def day
    return @days
  end
  
  def starts_on
    Time.utc(@page.year, @page.month, 1).wday
  end
  
  def ends_on
    Time.utc(@page.year, @page.month, days_in_month).wday
  end
  
  def add(event_objects, options={})
    raise ArgumentError, "Must specify :schedule_for attribute to assign events to days." unless options[:schedule_for]
    options[:html_class] ||= options[:schedule_for]
    event_objects.each do |event|
      schedule_for = event.send(options[:schedule_for])
      if schedule_for && schedule_for.month == @page.month && schedule_for.year == @page.year
        @events << options[:html_class] unless @events.include?(options[:html_class])
        @days[schedule_for.day][:events] << options[:html_class]
      end
    end
  end
  
  def generate(options={})
    options[:header_length] ||= 1
    options[:ignore_today]  ||= false
    build options
  end
  
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
  
end