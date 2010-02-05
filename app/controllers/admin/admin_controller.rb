class Admin::AdminController < ApplicationController
  # Toda a área de admin usa este template.
  layout "admin"

  before_filter :check_access, :admin_login_required
end