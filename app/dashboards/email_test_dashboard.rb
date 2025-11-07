require "administrate/custom_dashboard"

class EmailTestDashboard < Administrate::CustomDashboard
  resource "email_test"
end
