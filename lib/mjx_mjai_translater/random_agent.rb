this_dir = __dir__
lib_dir = File.join(this_dir, '../mjxproto')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'mjx_services_pb'

class RandomAgent < Mjxproto::Agent::Service
  def take_action(observation, _unused_call)
    observation.possible_actions.sample
  end
end

def main
  s = GRPC::RpcServer.new
  s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)
  s.handle(RandomAgent)
  s.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT'])
end

main
