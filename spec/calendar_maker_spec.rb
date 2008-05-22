$:.unshift(File.join(File.dirname(__FILE__), '..'))

require 'rubygems'
require 'spec'
require 'lib/calendar_maker.rb'

describe Calendar do
  attr_accessor :cal

  before(:each) do
    self.cal = Calendar.new
  end

  describe '#month' do
    it 'should retain the month of the calendar' do
      Calendar.new(:month => 5).month.should == 5
    end

    it 'should default to the current month' do
      Calendar.new.month.should == Time.now.month
    end
  end

  describe '#year' do
    it 'should retain the year of the calendar' do
      Calendar.new(:year => 2008).year.should == 2008
    end

    it 'should default to the current year' do
      Calendar.new.year.should == Time.now.year
    end
  end

  describe '#stars_on' do
    it 'should be the week day value for the first day of the month' do
      Calendar.new(:month => 10, :year => 2007).starts_on.should == 1
    end
  end

  describe '#days_in_month' do
    attr_accessor :expected_days_for_months

    before(:each) do
      self.expected_days_for_months = {
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
    end

    it 'should return the number of days in a month' do
      expected_days_for_months.each do |mon, count|
        Calendar.new(:month => mon, :year => 2008).days_in_month.should == count
      end
    end

    it 'should return 28 days for February, 2007' do
      Calendar.new(:month => 2, :year => 2007).days_in_month.should == 28
    end
  end

  describe '#days' do
    it 'should save a Hash of all events on a day' do
      cal.day.should be_a_kind_of(Hash)
    end

    it 'should have as many keys as there are days in the month' do
      cal.day.keys.length.should == cal.days_in_month
    end
  end

  describe '#events' do
    it 'should be an array of events for this calendar' do
      cal.events.should be_a_kind_of(Array)
    end

    it 'should be initialized as empty by default' do
      Calendar.new.events.should be_empty
    end
  end

  describe '#add' do
    it 'should add events to the specified day' do
      cal.add [stub('yesterday', :due_at => Time.now - days(1))], :schedule_for => :due_at
    end

    it 'should raise an ArgumentError if a :schedule_for option is missing' do
      lambda {
        cal.add(stub(:due_at => Time.now))
      }.should raise_error(ArgumentError)
    end
  end
  
  describe '#generate' do
    attr_accessor :calendar, :default_table, :table_with_events

    before(:each) do
      self.calendar          = Calendar.new(:month => 10, :year => 2007)
      self.default_table     = File.read('spec/fixtures/default_table.html').chomp
      self.table_with_events = File.read('spec/fixtures/table_with_events.html').chomp
    end
    it 'should generate an HTML calendar' do
      calendar.generate.should == default_table
    end

    it 'should add class names to days with events' do
      n = Time.mktime(2007, 10, 22, 21, 55, 8)
      Time.stub!(:now).and_return(n)
      calendar.add(
        [
          mock('5 days from now', :due_date => Time.now + days(5)), 
          mock('3 days from now', :due_date => Time.now + days(3))
        ], 
        :html_class   => 'due_date_class', 
        :schedule_for => :due_date
      )

      calendar.generate.should == table_with_events
    end
  end

  private
    def days(number_of_days)
      60 * 60 * 24 * number_of_days
    end
end
