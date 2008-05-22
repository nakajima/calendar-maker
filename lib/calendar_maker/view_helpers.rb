module ViewHelpers
  
  def build(options)
    output = %(<table class="calendar">)
    output.then_add(header)
    output.then_add weeks(options)
    output.then_add(%(</table>))
    return output
  end

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
    7.times do |i|
      output.then_add %(<th>#{Date::DAYNAMES[i][0..0]}</th>).tab(4)
    end
    output.then_add %(</tr>).tab(2)
  end
  
  # Generates the HTML table rows and cells for each week in a calendar.
  #
  # ==== Parameters
  # +options+ <Hash>:: a Hash of options that +day_attributes+ accepts
  #
  # ==== Returns
  # String
  def weeks(options={})
    output = ""
    @current_day = 1
    5.times do |week|
      output << "\n" unless week.zero?
      output << %(<tr class="week_#{week.succ}#{' last_row' if week == 4}">).tab(2)
      7.times do |day|
        output.then_add %(<td#{day_attributes(week.succ, day, options)}>#{day_view(week.succ, day)}</td>).tab(4)
      end
      output.then_add %(</tr>).tab(2)
    end
    return output
  end
  
  def day_attributes(week, day, options={})
    classes = []
    classes << 'inactive' unless test_field(week, day)
    classes << 'last_column' if day == 6
    classes.concat(days[@current_day][:events]) if days[@current_day] && !days[@current_day][:events].empty?
    html = ""
    html << %( class="#{classes.join(' ')}") unless classes.empty?
    if Time.now.mday == date.mday && Time.now.mon == date.mon
      html << %( id="today") unless options[:ignore_today]
    end
    return html
  end
  
  def test_field(week, day)
    !(
      (week == 1 && day < starts_on) ||
      (@current_day > days_in_month) ||
      (week == 5 && day > ends_on )
    )
  end
  
  def day_view(week, day)
    if test_field(week, day)
      response = %(<a href="#">#{@current_day}</a>)
      @current_day += 1
    else
      response = ""
    end
    return response
  end
  
end
