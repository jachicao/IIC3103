class ApplicationJob < ActiveJob::Base
  def get_auth_header(request_type, auth_params)
    temp_string = request_type
    auth_params.each do |k,v|
      temp_string.concat(v.to_s)
    end
    return 'INTEGRACION grupo' + ENV['GROUP_NUMBER'] + ':' + Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), ENV['STORE_HOUSE_PASSWORD'], temp_string))
  end
end
