# Load the rails application
require File.expand_path('../application', __FILE__)
Dir[Rails.root.join("lib/**/*.rb")].each {|f| require f}

# Initialize the rails application
Musevent::Application.initialize!
