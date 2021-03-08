require "mjx_action_to_mjai_action"

def find_proper_action_idx(mjai_action, mjai_possible_actions)
  return  0
end

def mjai_act_to_mjx_act(mjai_action, proto_possible_actions)
  mjai_possible_actions = mjai_possible_actions(proto_possible_actions)  #possible actions をmjaiのフォーマットに変換する
  proper_action_idx = find_proper_action_idx(mjai_action, mjai_possible_actions)
  return proto_possible_actions[proper_action_idx]
end
