class ApplicationController < ActionController::API
  #GET
  def token
    render json: { "token": 'abtj12312ab'}, status: 202
  end
end
