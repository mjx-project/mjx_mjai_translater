#! /usr/bin/env ruby
this_dir = __dir__
lib_dir = File.join(this_dir, '../mjxproto')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require_relative '../mjxproto/mjx/internal/mjx_pb'
require_relative '../mjxproto/mjx/internal/mjx_services_pb'
require 'grpc'

class RandomAgent < Mjxproto::Agent::Service
  def take_action(observation, _unused_call)
    observation.legal_actions.sample
  end
end

def main  # agentを1対立てる
  s = GRPC::RpcServer.new
  s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)
  s.handle(RandomAgent)
  s.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT'])
end

if __FILE__ == $0
  main
end
