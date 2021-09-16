require "mjx_to_mjai"
require "open_converter"
require 'action'
require_relative "../../mjai/lib/mjai/tcp_active_game_server"


class MjaiToMjx
  def initialize(absolutepos_id)
    @absolutepos_id_hash = absolutepos_id
    @absolute_pos = [0,1,
    2, 3]
  end

  def find_proper_action_idx(mjai_action, legal_actions)
    mjx_to_mjai = MjxToMjai.new(@absolutepos_id_hash, nil) # independent of target plyer
    if mjai_action.type == :dahai  && mjai_action.tsumogiri == false
      legal_actions.length.times do |i|
        action_type = legal_actions[i].type
        discard_in_mjai = mjx_to_mjai.proto_tile_to_mjai_tile(legal_actions[i].tile)
        if mjai_action.pai == discard_in_mjai && (action_type == :ACTION_TYPE_DISCARD)
          return i  # indexを返す
        end
      end
    end
    if mjai_action.type == :dahai  && mjai_action.tsumogiri == true
      legal_actions.length.times do |i|
        action_type = legal_actions[i].type
        discard_in_mjai = mjx_to_mjai.proto_tile_to_mjai_tile(legal_actions[i].tile)
        if mjai_action.pai == discard_in_mjai && (action_type == :ACTION_TYPE_TSUMOGIRI)
          return i  # indexを返す
        end
      end
    end
    if mjai_action.type == :chi
      legal_actions.length.times do |i|
        action_type = legal_actions[i].type
        if action_type == :ACTION_TYPE_CHI  # 牌の種類が同じかどうか
            open_converter = OpenConverter.new(legal_actions[i].open)
            stolen_tile_in_mjai = open_converter.mjai_stolen()
            consumed_tile_in_mjai = open_converter.mjai_consumed()
            if mjai_action.pai == stolen_tile_in_mjai && mjai_action.consumed == consumed_tile_in_mjai
              return i
            end
        end
      end
    end
    if mjai_action.type == :pon
      legal_actions.length.times do |i|
        action_type = legal_actions[i].type
        if action_type == :ACTION_TYPE_PON  # 牌の種類が同じかどうか
            open_converter = OpenConverter.new(legal_actions[i].open)
            stolen_tile_in_mjai = open_converter.mjai_stolen()
            consumed_tile_in_mjai = open_converter.mjai_consumed()
            if mjai_action.pai == stolen_tile_in_mjai && mjai_action.consumed == consumed_tile_in_mjai
              return i
            end
        end
      end
    end
    if mjai_action.type == :kakan
      legal_actions.length.times do |i|
        action_type = legal_actions[i].type
        if action_type == :ACTION_TYPE_ADDED_KAN  # 牌の種類が同じかどうか
            open_converter = OpenConverter.new(legal_actions[i].open)
            stolen_tile_in_mjai = open_converter.mjai_stolen()
            consumed_tile_in_mjai = open_converter.mjai_consumed()
            if mjai_action.pai == stolen_tile_in_mjai && mjai_action.consumed == consumed_tile_in_mjai
              return i
            end
        end
      end
    end
    if mjai_action.type == :daiminkan
      legal_actions.length.times do |i|
        action_type = legal_actions[i].type
        if action_type == :ACTION_TYPE_OPEN_KAN  # 牌の種類が同じかどうか
            open_converter = OpenConverter.new(legal_actions[i].open)
            stolen_tile_in_mjai = open_converter.mjai_stolen()
            consumed_tile_in_mjai = open_converter.mjai_consumed()
            if mjai_action.pai == stolen_tile_in_mjai && mjai_action.consumed == consumed_tile_in_mjai
              return i
            end
        end
      end
    end
    if mjai_action.type == :ankan
      legal_actions.length.times do |i|
        action_type = legal_actions[i].type
        if action_type == :ACTION_TYPE_CLOSED_KAN  # 牌の種類が同じかどうか
            open_converter = OpenConverter.new(legal_actions[i].open)
            stolen_tile_in_mjai = open_converter.mjai_stolen()
            consumed_tile_in_mjai = open_converter.mjai_consumed()
            if mjai_action.consumed == consumed_tile_in_mjai
              return i
            end
        end
      end
    end
    if mjai_action.type == :reach
      legal_actions.length.times do |i|
        action_type = legal_actions[i].type
        if action_type == :ACTION_TYPE_RIICHI
          return i
        end
      end
    end
    if mjai_action.type == :hora
      legal_actions.length.times do |i|
        action_type = legal_actions[i].type
        if action_type == :ACTION_TYPE_RON or action_type == :ACTION_TYPE_TSUMO  # mjaiはツモとロンを区別しない　同時に発生することはないので0K　
          return i
        end
      end
    end
    if mjai_action.type == :ryukyoku
    end
    if mjai_action.type == :none
      legal_actions.length.times do |i|
        action_type = legal_actions[i].type
        if action_type == :ACTION_TYPE_NO # mjaiはツモとロンを区別しない　同時に発生することはないので0K　
          return i
        end
      end
    end
  end

  def mjai_act_to_mjx_act(mjai_action, proto_legal_actions)  # mjxのpossible actionsをmjaiのactionに変換して照合するという方法を取る。なぜならmjxの方がactionの情報量が多い。
    #mjai_legal_actions = mjai_legal_actions(proto_legal_actions)  #possible actions をmjaiのフォーマットに変換する
    proper_action_idx = find_proper_action_idx(mjai_action, proto_legal_actions)
    return proto_legal_actions[proper_action_idx]
  end
end
