require 'test_helper'

class TinyXPathHelperTest < ActiveSupport::TestCase
  test "find first returns nil if there is no match" do
    xpath = TinyXPathHelper.new("<xml/>")
    assert xpath.first('*').nil?
  end

  test "find_xpath with :format => :array doesn't crash" do
    xpath = TinyXPathHelper.new("<xml><a/></xml>")
    assert xpath.find_xpath('*', :format => :array)
  end
end
