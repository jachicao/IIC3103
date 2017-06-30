if ENV['FACEBOOK_ACCESS_TOKEN'].nil?
  return nil
end

# access_token and other values aren't required if you set the defaults as described above
$facebook = Koala::Facebook::API.new(ENV['FACEBOOK_ACCESS_TOKEN'])