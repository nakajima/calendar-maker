namespace :calendar do
  desc "Puts HTML for a calendar"
  task :generate => :environment do
    @calendar = Calendar.new
    puts @calendar.generate
  end
end