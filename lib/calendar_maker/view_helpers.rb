module ViewHelpers
  # Generates the HTML for a calendar
  #
  # ==== Returns
  # String 
  def generate
    output = %(<table class="calendar">)
    output.then_add(header)
    output.then_add(weeks)
    output.then_add(%(</table>))
  end

  alias_method :to_html, :generate

  private
  
  # Generates the header for the calendar table.
  #
  # ==== Example
  #   <tr class="calendar_header">
  #     <th>S</th>
  #     <th>M</th>
  #     <th>T</th>
  #     <th>W</th>
  #     <th>T</th>
  #     <th>F</th>
  #     <th>S</th>
  #   </tr>
  def header
    output = %(<tr class="calendar_header">).tab(2)
    Date::DAYNAMES.each do |day_name|
      output.then_add ['<th>', day_name[0..0], '</th>'].join.tab(4)
    end
    output.then_add %(</tr>).tab(2)
  end

  attr_accessor :current_day
  
  # Generates the HTML table rows and cells for each week in a calendar.
  #
  # ==== Parameters
  # +options+ <Hash>:: a Hash of options that +day_attributes+ accepts
  #
  # ==== Returns
  # String
  def weeks(options={})
    output = ""
    self.current_day = 1
    5.times do |week|
      output << "\n" unless week.zero?
      output << %(<tr class="week_#{week.succ}#{' last_row' if week == 4}">).tab(2)
      7.times do |day|
        output.then_add %(<td#{day_attributes(week.succ, day)}>#{day_view(week.succ, day)}</td>).tab(4)
      end
      output.then_add %(</tr>).tab(2)
    end
    return output
  end
  
  # Generates the attributes for a day's TD tag. If the TD being generated 
  # represents today, the TD will have a 'today' ID.
  #
  # ==== Parameters
  # +week+ <Integer>:: the week under examination
  # +day+ <Integer>:: the day under examination
  def day_attributes(week, day)
    html  = %( class="#{day_attribute_classes(week, day)}")
    html << %( id="today") if Time.now.mday == date.mday && Time.now.mon == date.mon
    return html
  end

  # Ascertains the values for the +class+ attribute of a day's TD tag. If the 
  # day is weekend, or falls outside of the calendar, it will be given the 
  # +inactive+ class. Saturdays are given the +last_column+ class.
  #
  # ==== Parameters
  # +week+ <Integer>:: the week number in the month
  # +day+ <Integer>:: the week day number (see Time.wday)
  #
  # ==== Returns
  # String
  def day_attribute_classes(week, day)
    classes = []
    classes << 'inactive' unless day_inside_calendar?(week, day)
    classes << 'last_column' if day == 6
    classes.concat(days[current_day][:events]) if days[current_day] && !days[current_day][:events].empty?
    classes.join(' ')
  end
  
  # Tests to see if a given point falls outside the calendar.
  #
  # ==== Parameters
  # +week+ <Integer>:: the week number in the month
  # +day+ <Integer>:: the week day number (see Time.wday)
  def day_inside_calendar?(week, day)
    !(
      (week == 1 && day < starts_on)      ||
      (current_day > date.days_in_month) ||
      (week == 5 && day > ends_on )
    )
  end
  
  # Generates a link to the current day
  #
  # ==== Parameters
  # +week+ <Integer>:: the week number in the month
  # +day+ <Integer>:: the week day number (see Time.wday)
  #--
  # FIXME Empty days should have &nbsp;
  def day_view(week, day)
    if day_inside_calendar?(week, day)
      response = %(<a href="#">#{current_day}</a>)
      self.current_day = current_day.succ
    else
      response = ""
    end
    return response
  end
end
