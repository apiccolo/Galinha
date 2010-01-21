class Admin::AdminController < ApplicationController
  # Toda a área de admin usa este template.
  layout "admin"

  before_filter :admin_login_required

end