class ApplicationJob < ActiveJob::Base
  def get_auth_header(request_type, auth_params)
    tempString = request_type
    auth_params.each do |k,v|
      tempString.concat(v)
    end
    return "INTEGRACION grupo" + ENV["GROUP_NUMBER"] + ":" + Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), ENV["STORE_HOUSE_PASSWORD"], tempString))
  end
end
