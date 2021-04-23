require "mjx_to_mjai"
require "open_converter"
require_relative "../../mjai/lib/mjai/tcp_active_game_server"

class MjaiToMjx
  def initialize(absolutepos_id)
    @absolutepos_id_hash = absolutepos_id
    @absolute_pos = [:ABSOLUTE_POS_INIT_EAST,:ABSOLUTE_POS_INIT_SOUTH,
    :ABSOLUTE_POS_INIT_WEST, :ABSOLUTE_POS_INIT_NORTH]
  end

  def find_proper_action_idx(mjai_action, possible_actions)
    mjx_to_mjai = MjxToMjai.new(@absolutepos_id_hash)
    if mjai_action["type"] == "dahai"  # TODO ツモぎりもpossible actionsに加わる予定。 
      possible_actions.length.times do |i|
        action_type = possible_actions[i].type
        discard_in_mjai = mjx_to_mjai.proto_tile_to_mjai_tile(possible_actions[i].discard)
        if mjai_action["pai"] == discard_in_mjai && action_type == :ACTION_TYPE_DISCARD 
          return i  # indexを返す
        end
      end
    end
    if mjai_action["type"] == "chi"
      possible_actions.length.times do |i|
        action_type = possible_actions[i].type
        if action_type == :ACTION_TYPE_CHI  # 牌の種類が同じかどうか
            open_converter = OpenConverter.new(possible_actions[i].open)
            stolen_tile_in_mjai = open_converter.mjai_stolen()
            consumed_tile_in_mjai = open_converter.mjai_consumed()
            if mjai_action["pai"] == stolen_tile_in_mjai && mjai_action["consumed"] == consumed_tile_in_mjai
              return i
            end
        end
      end
    end
    if mjai_action["type"] == "pon"
      possible_actions.length.times do |i|
        action_type = possible_actions[i].type
        if action_type == :ACTION_TYPE_PON  # 牌の種類が同じかどうか
            open_converter = OpenConverter.new(possible_actions[i].open)
            stolen_tile_in_mjai = open_converter.mjai_stolen()
            consumed_tile_in_mjai = open_converter.mjai_consumed()
            if mjai_action["pai"] == stolen_tile_in_mjai && mjai_action["consumed"] == consumed_tile_in_mjai
              return i
            end
        end
      end
    end
    if mjai_action["type"] == "kakan"
      possible_actions.length.times do |i|
        action_type = possible_actions[i].type
        if action_type == :ACTION_TYPE_KAN_ADDED  # 牌の種類が同じかどうか
            open_converter = OpenConverter.new(possible_actions[i].open)
            stolen_tile_in_mjai = open_converter.mjai_stolen()
            consumed_tile_in_mjai = open_converter.mjai_consumed()
            if mjai_action["pai"] == stolen_tile_in_mjai && mjai_action["consumed"] == consumed_tile_in_mjai
              return i
            end
        end
      end
    end
    if mjai_action["type"] == "daiminkan"
      possible_actions.length.times do |i|
        action_type = possible_actions[i].type
        if action_type == :ACTION_TYPE_KAN_OPENED  # 牌の種類が同じかどうか
            open_converter = OpenConverter.new(possible_actions[i].open)
            stolen_tile_in_mjai = open_converter.mjai_stolen()
            consumed_tile_in_mjai = open_converter.mjai_consumed()
            if mjai_action["pai"] == stolen_tile_in_mjai && mjai_action["consumed"] == consumed_tile_in_mjai
              return i
            end
        end
      end
    end
    if mjai_action["type"] == "ankan"
    end
    if mjai_action["type"] == "reach"
    end
    if mjai_action["type"] == "hora"
      possible_actions.length.times do |i|
        action_type = possible_actions[i].type
        if action_type == :ACTION_TYPE_RON or action_type == :ACTION_TYPE_TSUMO  # mjaiはツモとロンを区別しない　同時に発生することはないので0K　
          return i
        end
      end
    end
    if mjai_action["type"] == "ryukyoku"
    end
    if mjai_action["type"] == "none"
      possible_actions.length.times do |i|
        action_type = possible_actions[i].type
        if action_type == :ACTION_TYPE_NO # mjaiはツモとロンを区別しない　同時に発生することはないので0K　
          return i
        end
      end
    end
  end

  def mjai_act_to_mjx_act(mjai_action, proto_possible_actions)  # mjxのpossible actionsをmjaiのactionに変換して照合するという方法を取る。なぜならmjxの方がactionの情報量が多い。
    #mjai_possible_actions = mjai_possible_actions(proto_possible_actions)  #possible actions をmjaiのフォーマットに変換する
    proper_action_idx = find_proper_action_idx(mjai_action, proto_possible_actions)
    return proto_possible_actions[proper_action_idx]
  end
end
