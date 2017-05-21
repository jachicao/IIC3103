class Api::ApiController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :check_header

  def check_header
    #authorization = request.headers['Authorization']
    #puts authorization
    #if authorization.nil?
    #  return render :json => {
    #    :error => 'Authorization header needed'
    #  }, status: :unauthorized
    #end
    #producer = Producer.all.find_by(producer_id: authorization);
    #if producer.nil?
    #  return render :json => {
    #      :error => 'Wrong Authorization'
    #  }, status: :unauthorized
    #end
  end
end
