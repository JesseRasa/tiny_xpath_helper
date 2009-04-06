require 'test_helper'

class TinyXPathHelperTest < ActiveSupport::TestCase
  test "find first returns nil if there is no match" do
    xpath = TinyXPathHelper.new("<xml/>")
    assert xpath.first('*').nil?
  end
end
