require 'test_helper'

class FedExTest < Test::Unit::TestCase
  def setup
    @packages               = TestFixtures.packages
    @locations              = TestFixtures.locations
    @carrier                = FedEx.new(:key => '1111', :password => '2222', :account => '3333', :login => '4444')
  end
  
  def test_initialize_options_requirements
    assert_raises ArgumentError do FedEx.new end
    assert_raises ArgumentError do FedEx.new(:login => '999999999') end
    assert_raises ArgumentError do FedEx.new(:password => '7777777') end
    assert_nothing_raised { FedEx.new(:key => '999999999', :password => '7777777', :account => '123', :login => '123')}
  end
  
  # def test_no_rates_response
  #   @carrier.expects(:commit).returns(xml_fixture('fedex/empty_response'))
  # 
  #   response = @carrier.find_rates(
  #     @locations[:ottawa],                                
  #     @locations[:beverly_hills],            
  #     @packages.values_at(:book, :wii)
  #   )
  #   assert_equal "WARNING - 556: There are no valid services available. ", response.message
  # end
  
  def test_find_tracking_info_should_return_a_tracking_response
    @carrier.expects(:commit).returns(xml_fixture('fedex/tracking_response'))
    assert_instance_of ActiveMerchant::Shipping::TrackingResponse, @carrier.find_tracking_info('077973360403984', :test => true)
  end
  
  def test_find_tracking_info_should_parse_response_into_correct_number_of_shipment_events
    @carrier.expects(:commit).returns(xml_fixture('fedex/tracking_response'))
    response = @carrier.find_tracking_info('077973360403984', :test => true)
    assert_equal 7, response.shipment_events.size
  end
  
  def test_find_tracking_info_should_return_shipment_events_in_ascending_chronological_order
    @carrier.expects(:commit).returns(xml_fixture('fedex/tracking_response'))
    response = @carrier.find_tracking_info('077973360403984', :test => true)
    assert_equal response.shipment_events.map(&:time).sort, response.shipment_events.map(&:time)
  end
  
  def test_building_request_and_parsing_response
    expected_request = xml_fixture('fedex/ottawa_to_beverly_hills_rate_request')
    mock_response = xml_fixture('fedex/ottawa_to_beverly_hills_rate_response')
    Time.any_instance.expects(:to_xml_value).returns("2009-07-20T12:01:55-04:00")
    
    @carrier.expects(:commit).with {|request, test_mode| Hash.from_xml(request) == Hash.from_xml(expected_request) && test_mode}.returns(mock_response)
    response = @carrier.find_rates( @locations[:ottawa],
                                    @locations[:beverly_hills],
                                    @packages.values_at(:book, :wii), :test => true)
    assert_equal ["FedEx Ground"], response.rates.map(&:service_name)
    assert_equal [3836], response.rates.map(&:price)
    
    assert response.success?, response.message
    assert_instance_of Hash, response.params
    assert_instance_of String, response.xml
    assert_instance_of Array, response.rates
    assert_not_equal [], response.rates
    
    rate = response.rates.first
    assert_equal 'FedEx', rate.carrier
    assert_equal 'CAD', rate.currency
    assert_instance_of Fixnum, rate.total_price
    assert_instance_of Fixnum, rate.price
    assert_instance_of String, rate.service_name
    assert_instance_of String, rate.service_code
    assert_instance_of Array, rate.package_rates
    assert_equal @packages.values_at(:book, :wii), rate.packages
    
    package_rate = rate.package_rates.first
    assert_instance_of Hash, package_rate
    assert_instance_of Package, package_rate[:package]
    assert_nil package_rate[:rate]
  end
  
  def test_service_name_for_code
    FedEx::ServiceTypes.each do |capitalized_name, readable_name|
      assert_equal readable_name, FedEx.service_name_for_code(capitalized_name)
    end
  end
  
  def test_service_name_for_code_handles_yet_unknown_codes
    assert_equal "FedEx Express Saver Saturday Delivery", FedEx.service_name_for_code('FEDEX_EXPRESS_SAVER_SATURDAY_DELIVERY')
    assert_equal "FedEx Some Weird Rate", FedEx.service_name_for_code('SOME_WEIRD_RATE')
  end
  
  
end