require './lib/mjx_mjai_translater/trans_server'
require './lib/mjx_mjai_translater/action'
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "test_utils"


RSpec.describe MjxMjaiTranslater do
  it 'has a version number' do
    expect(MjxMjaiTranslater::VERSION).not_to be nil
  end
  it 'does something useful' do
    expect(true).to eq(true)
  end
end

RSpec.describe TransServer do  # take_actionで実装されている階層の関数をtest
  file = File.open("spec/resources/observations-000.json", "r")
  lines = file.readlines
  trans_server = TransServer.new({:target_id=>1, "test"=>"yes"})
  it 'test_observe' do
    previous_events = observation_from_json(lines, 0).public_observation.events
    observation = observation_from_json(lines, 1)
    p "aaaa"
    trans_server.set_mjx_events(previous_events)
    trans_server.observe(observation)
    #expect(trans_server.new_mjai_acitons)
  end
  it 'test_update_next_action' do
  end
end