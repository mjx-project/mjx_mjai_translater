require 'grpc'
require './lib/mjxproto/mjx/internal/mjx_pb'
require './lib/mjxproto/mjx/internal/mjx_services_pb'
require 'google/protobuf'


def observation_from_json(lines,line)  # 特定の行を取得する
    json = JSON.load(lines[line])
    json_string = Google::Protobuf.encode_json(json)
    proto_observation = Google::Protobuf.decode_json(Mjxproto::Observation, json_string)
end