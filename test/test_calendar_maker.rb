$:.unshift(File.join(File.dirname(__FILE__), '..'))

require 'time'
require 'rubygems'
require 'spec'
require 'test/unit'
require 'lib/calendar_maker.rb'

describe Calendar do
  def setup
    @calendar          = Calendar.new
    @default_table     = File.read('test/fixtures/default_table.html').chomp
    @table_with_events = File.read('test/fixtures/table_with_events.html').chomp
  end

  def test_should_have_calendar_class
    assert_not_nil Calendar
  end
  
  def test_should_have_month_and_year_readers
    assert_respond_to @calendar, :month
    assert_respond_to @calendar, :year
  end
  
  def test_should_create_internal_time_object
    assert_equal Time, @calendar.instance_variable_get(:@page).class
  end
  
  def test_should_use_current_month_and_year_page_non_are_specified
    assert_equal Time.now.month, @calendar.month
    assert_equal Time.now.year, @calendar.year
  end
  
  def test_should_assign_different_month_and_year
    @old_calendar = Calendar.new(:month => 1, :year => 1922)
    assert_equal 1, @old_calendar.month
    assert_equal 1922, @old_calendar.year
  end

  def test_should_find_wday_for_first_day_of_week
    @current_calendar = Calendar.new(:month => 10, :year => 2007)
    assert_equal 1, @current_calendar.starts_on
  end
  
  def test_should_return_day_count_for_months
    leap_months = {
      'jan' => 31, 
      'feb' => 29, 
      'mar' => 31, 
      'apr' => 30, 
      'may' => 31, 
      'jun' => 30, 
      'jul' => 31, 
      'aug' => 31, 
      'sep' => 30, 
      'oct' => 31, 
      'nov' => 30, 
      'dec' => 31
    }
    leap_months.each do |mon, count|
      assert_equal count, Calendar.new(:month => mon, :year => 2008).days_in_month
    end
  end

  def test_should_have_days
    assert_equal Hash, @calendar.instance_variable_get(:@days).class
    assert_equal @calendar.days_in_month, @calendar.instance_variable_get(:@days).keys.length
  end
  
  def test_should_access_day
    assert_respond_to @calendar, :day
  end
  
  def test_should_have_events_list
    assert_equal Array, @calendar.instance_variable_get(:@events).class
  end
  
  def test_should_add_events_and_set_instance_variable
    todos = []
    5.times { todos << mock('todo', :due_at_date => Time.now) }
    assert_not_equal(
      @calendar.instance_variable_get(:@events).length, 
      @calendar.add(todos, :schedule_for => :due_at_date)
    )
  end
  
  def test_should_require_schedule_for_option
    todos = []
    5.times { todos << stub(:due_at_date => Time.now) }
    assert_raises ArgumentError do
      @calendar.add todos
    end
  end
  
  def test_should_assign_event_to_appropriate_day
    todos = []
    todos << todo_for_today = stub('today', :due_at_date => Time.now)
    todos << todo_for_yesterday = stub('yesterday', :due_at_date => Time.now - days(1))
    @calendar.add todos, :schedule_for => :due_at_date, :html_class => "today"
    todos.each do |todo|
      assert @calendar.instance_variable_get(:@events).include?('today')
    end
    assert @calendar.day[Time.now.day][:events].include?('today')
    assert @calendar.day[Time.now.day - 1][:events].include?('today')
  end
  
  def test_should_generate_calendar_html
    @calendar = Calendar.new(:month => "oct", :year => 2007)
    assert_equal @default_table, @calendar.generate 
  end
  
  def test_should_add_class_names_to_days_with_events
    n = Time.parse("Mon Oct 22 21:55:08 -0400 2007")
    Time.stub!(:now).and_return(n)
    @calendar = Calendar.new(:month => 'oct', :year => 2007)
    @calendar.add(
      [
        mock('5 days from now', :due_date => Time.now + days(5)), 
        mock('3 days from now', :due_date => Time.now + days(3))
      ], 
      :html_class   => 'due_date_class', 
      :schedule_for => :due_date
    )
    assert_equal @table_with_events, @calendar.generate
  end

private
  def days(number_of_days)
    60 * 60 * 24 * number_of_days
  end
end
