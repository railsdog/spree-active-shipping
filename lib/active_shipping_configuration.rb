class ActiveShippingConfiguration < Configuration

  preference :ups_login, :string, :default => "aunt_judy"
  preference :ups_password, :string, :default => "secret"
  preference :ups_key, :string, :default => "developer_key"
  
  preference :fedex_login, :string, :default => "meter_no"
  preference :fedex_password, :string, :default => "special_sha1_looking_thing_sent_via_email"
  preference :fedex_account, :string, :default => "account_no"
  preference :fedex_key, :string, :default => "authorization_key"

  preference :origin_country, :string, :default => "US"
  preference :origin_state, :string, :default => "2 Letter State"
  preference :origin_city, :string, :default => "City"
  preference :origin_zip, :string, :default => "5 digit Zip"
  
  preference :units, :string, :default => "imperial"
  preference :unit_multiplier, :integer, :default => 1 # 16 oz./lb - assumes variant weights are in ozs
  
  #validates_presence_of :name
  #validates_uniqueness_of :name
end
