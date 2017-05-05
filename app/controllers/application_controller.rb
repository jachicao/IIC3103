class ApplicationController < ActionController::API
  protect_from_forgery with: :exception
  #GET
  def token
    render json: { "token": 'abtj12312ab'}, status: 202
  end
end
