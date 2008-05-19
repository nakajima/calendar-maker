module ViewHelpers
  
  DAYS_OF_THE_WEEK = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']
  
  def build(options)
    output = %(<table class="calendar">)
    output.then_add header(options[:header_length])
    output.then_add weeks(options)
    output.then_add %(</table>)
    return output
  end
  
  def header(options={})
    output = %(<tr class="calendar_header">).tab(2)
    7.times do |i|
      output.then_add %(<th>#{DAYS_OF_THE_WEEK[i][0..0]}</th>).tab(4)
    end
    output.then_add %(</tr>).tab(2)
  end
  
  def weeks(options={})
    output = ""
    @current_day = 1
    5.times do |week|
      output << "\n" unless week == 0
      output << %(<tr class="week_#{week+1}#{' last_row' if week == 4}">).tab(2)
      7.times do |day|
        output.then_add %(<td#{day_attributes(week+1, day, options)}>#{day_view(week+1, day)}</td>).tab(4)
      end
      output.then_add %(</tr>).tab(2)
    end
    return output
  end
  
  def day_attributes(week, day, options={})
    classes = []
    classes << 'inactive' unless test_field(week, day)
    classes << 'last_column' if day == 6
    classes.concat(@days[@current_day][:events]) if @days[@current_day] && !@days[@current_day][:events].empty?
    html = ""
    html << %( class="#{classes.join(' ')}") unless classes.empty?
    if Time.now.mday == @page.mday && Time.now.mon == @page.mon
      html << %( id="today") unless options[:ignore_today]
    end
    return html
  end
  
  def test_field(week, day)
    return true unless ( week == 1 && day < starts_on ) or ( @current_day > days_in_month ) or ( week == 5 && day > ends_on )
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
