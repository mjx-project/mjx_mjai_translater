require "test/unit"
require '../mjx_mjai_translater/observation_to_mjai_state'

class TestTranslator < Test::Unit::TestCase
  def test_mjai_to_mjx
    assert_equal(0, observation_to_mjai_states)
  end
end
