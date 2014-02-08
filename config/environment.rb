# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
SharedDirectory::Application.initialize!

Date::DATE_FORMATS.merge!(
  default: '%d/%m/%Y'
)