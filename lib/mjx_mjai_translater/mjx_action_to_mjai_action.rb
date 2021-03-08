# possibleactionsをmjaiのactionのフォーマットに変換する
#require "./open_converter.rb"


class MjxActToMjaiAct

  def initialize(proto_possible_actions)
    @proto_acitons = proto_possible_actions
  end


  def proto_tile_to_mjai_tile(proto_tile)  # 他のクラスに
    reds_in_proto = [16, 52, 88]
    reds_dict = {16 => "5mr", 52 => "5sr", 88 => "5pr"}
    m_kind_dict = {0 => "m", 1 => "s", 2 => "p"}
    if reds_in_proto.include?(proto_tile)
      return reds_dict[proto_tile]
    end
    if proto_tile.div(36) <= 2
      return (proto_tile.div(36).quo(4) + 1).to_i.to_s + m_kind_dict[proto_tile.div(36)]
    end
  end
end
