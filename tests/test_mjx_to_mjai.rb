require "test/unit"
require "./observation_to_mjai_states"

class TestTranslator < Test::Unit::TestCase
  def test_mjai_to_mjx
    assert_equal(0, observation_to_mjai_states)
