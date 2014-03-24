desc "These are tasks that have to be performed using scheduler. Schedulers are different on different environments"

task archive_outdated_events: :environment do
  puts "Task will find expired events and mark them as archived"
  checker = EventStateChecker.new

  failed_raising = checker.archive_failed_raising
  puts "#{failed_raising} #{"event".pluralize failed_raising} have not raised enough and were moved to archive"

  passed_events = checker.archive_passed
  puts "#{passed_events} #{"event".pluralize passed_events} have passed and were moved to archive"
end