# possibleactionsをmjaiのactionのフォーマットに変換する
#require "./open_converter.rb"


class MjxActToMjaiAct   # mjaiのアクションをmjxの者に変換する際に,mjxのpossible actionsとの照合をするため。

  def initialize(proto_possible_actions)
    @proto_acitons = proto_possible_actions
  end


  def proto_tile_to_mjai_tile(proto_tile)  # 他のクラスに
    reds_in_proto = [16, 52, 88]
    reds_dict = {16 => "5mr", 52 => "5sr", 88 => "5pr"}
    mod36_kind_dict = {0 => "m", 1 => "s", 2 => "p"}
    num_zihai_dict = {0 => "E", 1 => "S", 2 => "W", 3 => "N", 4 => "P", 5 => "F", 6 => "C"}
    if reds_in_proto.include?(proto_tile)  # 赤
      return reds_dict[proto_tile]
    end
    if proto_tile.div(36) < 2  #数牌
      return ((proto_tile % 36 ).div(4) + 1).to_i.to_s + mod36_kind_dict[proto_tile.div(36)]
    end
    return num_zihai_dict[(proto_tile % 36).div(4)]  #字牌
  end
end
