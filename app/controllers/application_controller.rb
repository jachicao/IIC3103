require 'openssl'
require 'base64'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  #before_action :before

  # e.g. get_auth_header("GET", { almacenId: "534960ccc88ee69029cd3fb2" })
  def get_auth_header(request_type, body_params)
  	tempString = request_type
  	body_params.each do |k,v|
  		tempString.concat(v)
  	end
   	return "INTEGRACION grupo" + ENV["GROUP_NUMBER"] + ":" + Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), ENV["STORE_HOUSE_PASSWORD"], tempString))
  end

  def before
    req_params = { :almacenId => "590baa76d6b4ec000490247c" };
  	res = HTTParty.get(ENV['CENTRAL_SERVER_URL'] + '/bodega/skusWithStock', :query => req_params, :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("GET", req_params) } );
  	puts res.body;
  end
end