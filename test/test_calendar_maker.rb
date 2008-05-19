require File.join(File.dirname(__FILE__), '..', 'lib/calendar_maker.rb')
require 'rubygems'
require 'mocha'
require 'test/unit'

class TestCalendarMaker < Test::Unit::TestCase
  def setup
    @calendar = Calendar.new
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
    months = {  'jan' => 31, 'feb' => 28, 'mar' => 31, 'apr' => 30, 'may' => 31, 'jun' => 30,
                'jul' => 31, 'aug' => 31, 'sep' => 30, 'oct' => 31, 'nov' => 30, 'dec' => 31  }
    months.each do |mon, count|
      assert_equal count, Calendar.new(:month => mon).days_in_month
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
    5.times { todos << stub(:due_at_date => Time.now) }
    assert_difference '@calendar.instance_variable_get(:@events).length' do
      @calendar.add todos, :schedule_for => :due_at_date
    end
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
    todos << todo_for_today = stub(:due_at_date => Time.now)
    todos << todo_for_yesterday = stub(:due_at_date => Time.now - 1.day)
    @calendar.add todos, :schedule_for => :due_at_date, :html_class => "today"
    todos.each do |todo|
      assert @calendar.instance_variable_get(:@events).include?('today')
    end
    assert @calendar.day[Time.now.day][:events].include?('today')
    assert @calendar.day[Time.now.day - 1][:events].include?('today')
  end
  
  def test_should_generate_calendar_html
    @calendar = Calendar.new(:month => "oct", :year => 2007)
    result = File.read("#{File.dirname(__FILE__)}/fixtures/default_table.html")
    assert_equal result, @calendar.generate
  end
  
  def test_should_add_class_names_to_days_with_events
    n = Time.parse("Mon Oct 22 21:55:08 -0400 2007")
    Time.stubs(:now).returns(n)
    @calendar = Calendar.new(:month => "oct", :year => 2007)
    @calendar.add [stub(:due_date => Time.now + 5.days), stub(:due_date => Time.now + 3.days)], :html_class => 'due_date_class', :schedule_for => :due_date
    result = File.read("#{File.dirname(__FILE__)}/fixtures/table_with_events.html")
    assert_equal result, @calendar.generate
  end
  
end
