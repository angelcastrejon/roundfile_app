module Admin
  class BaseController < ApplicationController
    before_action :authenticate!
    before_action :authorize_admin!

    layout "admin"
  end
end
