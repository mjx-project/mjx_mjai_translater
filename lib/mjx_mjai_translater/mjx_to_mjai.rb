# possibleactionsをmjaiのactionのフォーマットに変換する
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require "open_converter.rb"
this_dir = __dir__
lib_dir = File.join(this_dir, '../mjxproto')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require './lib/mjxproto/mjx/internal/mjx_pb'
require './lib/mjxproto/mjx/internal/mjx_services_pb'
require 'google/protobuf'
require "minitest"
require_relative "../../mjai/lib/mjai/pai"

include Minitest::Assertions


class MjxYakuToMjaiYaku
  def initialize()
    @mjai_yaku_list = [
      :menzenchin_tsumo,
      :reach,
      :ippatsu,
      :chankan,
      :rinshankaiho,
      :haiteiraoyui,
      :houteiraoyui,
      :pinfu,
      :tanyaochu,
      :ipeko,
      :jikaze,
      :jikaze,
      :jikaze,
      :jikaze,
      :bakaze,
      :bakaze,
      :bakaze,
      :bakaze,
      :sangenpai,
      :sangenpai,
      :sangenpai,
      :double_reach,
      :chitoitsu,
      :honchantaiyao,
      :ikkitsukan,
      :sansyokudojun,
      :sanshokudoko,
      :sankantsu,
      :toitoiho,
      :sananko,
      :shosangen,
      :honroto,
      :ryanpeko,
      :junchantaiyao,
      :honiso,
      :chiniso,
      :renho,  # 天鳳は人和なし
      :tenho,
      :chiho,
      :daisangen,
      :suanko,
      :suanko,
      :tsuiso,
      :ryuiso,
      :chinroto,
      :churenpoton,
      :churenpoton,
      :kokushimuso,
      :kokushimuso,
      :daisushi,
      :shosushi,
      :sukantsu,
      :dora,
      :uradora,
      :akadora,
  ]
    @ryukyoku_reasons_dict = {
      :EVENT_TYPE_ABORTIVE_DRAW_FOUR_RIICHIS=>:suchareach,
      :EVENT_TYPE_ABORTIVE_DRAW_THREE_RONS=>:sanchaho,  
      :EVENT_TYPE_ABORTIVE_DRAW_FOUR_KANS=>:sukaikan,
      :EVENT_TYPE_ABORTIVE_DRAW_FOUR_WINDS=>:sufonrenta,
      :EVENT_TYPE_EXHAUSTIVE_DRAW_NORMAL=>:fonpai,
      :EVENT_TYPE_EXHAUSTIVE_DRAW_NAGASHI_MANGAN=>:nagashimangan
}
  end

  def mjai_yaku(mjx_yaku_idx)
    @mjai_yaku_list[mjx_yaku_idx]
  end

  def mjai_reason(mjx_event)
    return @ryukyoku_reasons_dict[mjx_event]
  end
end


class MjxToMjai   #  mjxからmjaiへの変換関数をまとめる。　クラスじゃなくても良いかも
  attr_accessor :assertions
  attr_reader(:target_id)
  def initialize(absolutepos_id, target_id)
    @absolutepos_id_hash = absolutepos_id
    @absolute_pos = [0,1,2, 3]
    @target_id = target_id
    self.assertions = 0
  end


  def proto_tile_to_mjai_tile(proto_tile)
    reds_in_proto = [16, 52, 88]
    reds_dict = {16 => "5mr", 52 => "5pr", 88 => "5sr"}
    mod36_kind_dict = {0 => "m", 1 => "p", 2 => "s"}
    num_zihai_dict = {0 => "E", 1 => "S", 2 => "W", 3 => "N", 4 => "P", 5 => "F", 6 => "C"}
    if reds_in_proto.include?(proto_tile)  # 赤
      return Mjai::Pai.new(reds_dict[proto_tile])
    end
    if proto_tile.div(36) <= 2  #数牌
      tile_num = ((proto_tile % 36 ).div(4) + 1).to_i.to_s + mod36_kind_dict[proto_tile.div(36)]
      return Mjai::Pai.new(tile_num.to_s)
    end
    return Mjai::Pai.new(num_zihai_dict[(proto_tile % 36).div(4)])  #字牌
  end


  def proto_tiles_to_mjai_tiles(proto_tiles)
    mjai_tiles = []
    proto_tiles.length.times do |i|
      mjai_tiles.push(proto_tile_to_mjai_tile(proto_tiles[i]))
    end
    return mjai_tiles
  end


  def mjx_event_to_mjai_action(event, observation, players)  # observationはreach_accepted, ron tsumoの時しか使わない。
    if event.type == :EVENT_TYPE_DRAW
      if event.who != @target_id
        return Mjai::Action.new({:type=>:tsumo,:actor=>@absolutepos_id_hash[event.who],:pai=>Mjai::Pai.new("?")})  # ツモ牌 全て？で統一
      else
        return Mjai::Action.new({:type=>:tsumo,:actor=>@absolutepos_id_hash[event.who],:pai=>proto_tile_to_mjai_tile(observation.private_observation.draw_history[-1])})
      end
    end
    if event.type == :EVENT_TYPE_DISCARD
      return Mjai::Action.new({:type=>:dahai, :actor=>@absolutepos_id_hash[event.who], :pai=>proto_tile_to_mjai_tile(event.tile), :tsumogiri=>false})
    end
    if event.type == :EVENT_TYPE_TSUMOGIRI
      return Mjai::Action.new({:type=>:dahai, :actor=>@absolutepos_id_hash[event.who], :pai=>proto_tile_to_mjai_tile(event.tile), :tsumogiri=>true})
    end 
    if event.type == :EVENT_TYPE_CHI || event.type == :EVENT_TYPE_PON || event.type == :EVENT_TYPE_OPEN_KAN  # pon, chi, daiminkan
      open_converter = OpenConverter.new(event.open)
      type = open_converter.open_event_type()
      current_pos = event.who
      pos_index = @absolute_pos.find_index(current_pos)
      relative_pos = open_converter.open_from()
      target_index = (pos_index + relative_pos) % 4
      target = @absolute_pos[target_index] # absolute_posを表すsymbol object
      stolen_tile = open_converter.mjai_stolen()
      consumed_tile = open_converter.mjai_consumed()
      return Mjai::Action.new({:type=>type, :actor=>@absolutepos_id_hash[event.who], :target=>@absolutepos_id_hash[target], :pai=>stolen_tile, :consumed=>consumed_tile})
    end
    if event.type == :EVENT_TYPE_ADDED_KAN  # kakan
      open_converter = OpenConverter.new(event.open)
      type = open_converter.open_event_type()
      stolen_tile = open_converter.mjai_stolen()
      consumed_tile = open_converter.mjai_consumed()
      return Mjai::Action.new({:type=>type, :actor=>@absolutepos_id_hash[event.who], :pai=>stolen_tile, :consumed=>consumed_tile})
    end
    if event.type == :EVENT_TYPE_CLOSED_KAN  # ankan
      open_converter = OpenConverter.new(event.open)
      type = open_converter.open_event_type()
      consumed_tile = open_converter.mjai_consumed()
      return Mjai::Action.new({:type=>type, :actor=>@absolutepos_id_hash[event.who],:consumed=>consumed_tile})
    end
    if event.type == :EVENT_TYPE_NEW_DORA
      return Mjai::Action.new({:type=>:dora, :dora_marker=>proto_tile_to_mjai_tile(event.tile)})
    end
    if event.type == :EVENT_TYPE_RIICHI
      return Mjai::Action.new({:type=>:reach, :actor=>@absolutepos_id_hash[event.who]})
    end
    if event.type == :EVENT_TYPE_RIICHI_SCORE_CHANGE
        ten_change = [0,0,0,0]
        pos_index = @absolute_pos.find_index(event.who)
        ten_change[pos_index] = -1000
        scores = observation.public_observation.init_score.tens
        scores[pos_index] -= 1000
        return  Mjai::Action.new({:type=>:reach_accepted,:actor=>@absolutepos_id_hash[event.who], :deltas=>ten_change, :scores=>scores})
    end
    if observation.round_terminal != nil
      assert_types = [:EVENT_TYPE_RON, :EVENT_TYPE_TSUMO,:EVENT_TYPE_ABORTIVE_DRAW_FOUR_RIICHIS, :EVENT_TYPE_ABORTIVE_DRAW_THREE_RONS, :EVENT_TYPE_ABORTIVE_DRAW_FOUR_KANS,
      :EVENT_TYPE_ABORTIVE_DRAW_FOUR_WINDS, :EVENT_TYPE_EXHAUSTIVE_DRAW_NORMAL, :EVENT_TYPE_EXHAUSTIVE_DRAW_NAGASHI_MANGAN]
      assert_includes assert_types, event.type
      return mjx_terminal_to_mjai_action(event, observation, players)
    end
  end

  def mjx_act_to_mjai_act(mjx_act, public_observatoin) 
    # この関数はtrans_serverの内部で実行されるのでprevious_historyは問題なく手に入る 
    #　またこの関数が実行される際には@_mjx_public_observatoinが最新のものに更新されているので欲しいactionが含まれていないという心配もない
    action_type = mjx_act.type
    who = mjx_act.who
    if action_type == :ACTION_TYPE_DISCARD #新しいprotoを待つ
      tile = mjx_act.tile
      return Mjai::Action.new({:type=>:dahai, :actor=>@absolutepos_id_hash[who], :pai=>proto_tile_to_mjai_tile(tile), :tsumogiri=>false})
    end
    if action_type == :ACTION_TYPE_TSUMOGIRI
      tile = mjx_act.tile
      return Mjai::Action.new({:type=>:dahai, :actor=>@absolutepos_id_hash[who], :pai=>proto_tile_to_mjai_tile(tile), :tsumogiri=>true})
    end
    if action_type == :ACTION_TYPE_CHI || action_type == :ACTION_TYPE_PON || action_type == :ACTION_TYPE_OPEN_KAN
      open_converter = OpenConverter.new(mjx_act.open)
      type = open_converter.open_event_type()
      current_pos = who
      pos_index = @absolute_pos.find_index(current_pos)
      relative_pos = open_converter.open_from()
      target_index = (pos_index + relative_pos) % 4
      target = @absolute_pos[target_index] # absolute_posを表すsymbol object
      stolen_tile = open_converter.mjai_stolen()
      consumed_tile = open_converter.mjai_consumed()
      return Mjai::Action.new({:type=>type, :actor=>@absolutepos_id_hash[who], :target=>@absolutepos_id_hash[target], :pai=>stolen_tile, :consumed=>consumed_tile})
    end
    if action_type == :ACTION_TYPE_ADDED_KAN  # kakan
      open_converter = OpenConverter.new(mjx_act.open)
      type = open_converter.open_event_type()
      stolen_tile = open_converter.mjai_stolen()
      consumed_tile = open_converter.mjai_consumed()
      return Mjai::Action.new({:type=>type, :actor=>@absolutepos_id_hash[who], :pai=>stolen_tile, :consumed=>consumed_tile})
    end
    if action_type == :ACTION_TYPE_CLOSED_KAN  # ankan
      open_converter = OpenConverter.new(mjx_act.open)
      type = open_converter.open_event_type()
      consumed_tile = open_converter.mjai_consumed()
      return Mjai::Action.new({:type=>type, :actor=>@absolutepos_id_hash[who],:consumed=>consumed_tile})
    end
    if action_type == :ACTION_TYPE_RIICHI
      return Mjai::Action.new({:type=>:reach, :actor=>@absolutepos_id_hash[who]})
    end
    if action_type == :ACTION_TYPE_RON || action_type == :ACTION_TYPE_TSUMO # trans_serverが持っている previous_public_observatoinの情報を使う
      last_event = public_observatoin[-1]
      assert_types = [:EVENT_TYPE_TSUMOGIRI, :EVENT_TYPE_DISCARD, :EVENT_TYPE_DRAW, :EVENT_TYPE_ADDED_KAN]
      assert_includes assert_types, last_event.type
      target = last_event.who
      hora_tile = mjx_act.tile
      return Mjai::Action.new({:type=>:hora,:actor=>@absolutepos_id_hash[who],:target=>@absolutepos_id_hash[target],:pai=>proto_tile_to_mjai_tile(hora_tile)})
    end
    if action_type == :ACTION_TYPE_NO
      return Mjai::Action.new({:type=>:none})
    end
  end


  def mjx_terminal_to_mjai_action(event, observation, players)
    terminal_info = observation.round_terminal.wins
    if terminal_info != []
      return mjx_win_terminal_to_mjai_action(observation)
    end
    return mjx_no_win_terminal_to_mjai_action(event, observation, players)
  end


  def mjx_no_win_terminal_to_mjai_action(event, observation, players) # 流局時はplayer classから手配の情報を取得する必要がある。
    mjx_yaku_to_mjai_yaku = MjxYakuToMjaiYaku.new()
    terminal_info = observation.round_terminal.no_winner # 流局時の情報が格納されている。
    reason = mjx_yaku_to_mjai_yaku.mjai_reason(event.type)
    terminal_hands =  _terminal_hand(terminal_info, players)
    tenpais = [0, 1, 2, 3].map {|x| terminal_info.tenpais.map{|x| x.who}.include?(x)} # 聴牌者のidに含まれているか booleanのリスト
    delta = terminal_info.ten_changes
    init_scores = observation.public_observation.init_score.tens
    changed_scores = init_scores.zip(delta).map{|n,p| n+p}
    return Mjai::Action.new({:type=>:ryukyoku, :reason=>reason, :tehais=>terminal_hands, :tenpais=>tenpais, :deltas=>delta, :scores=>changed_scores })
  end


  def _terminal_hand(terminal_info, players)  # mjaiには聴牌者の手配ははいの情報を入れ、ノーテンのplayerの手牌は?でうめる。
    tenpais = terminal_info.tenpais  # 聴牌者の情報
    tenpai_players = tenpais.map {|x| x.who}
    tenpai_closed_hands = tenpais.map{|x| x.hand.closed_tiles}# mjaiはclosed_tileしか渡していない
    terminal_hands = []
    players.length.times do |i|
      if !tenpai_players.include?(i)
        terminal_hands.push([Mjai::Pai.new("?")]*players[i].hand.length)
      else
        terminal_hands.push(proto_tiles_to_mjai_tiles(tenpai_closed_hands.shift()))
      end
    end
    return terminal_hands
  end

  def mjx_win_terminal_to_mjai_action(observation)  # winnerがいる場合
    terminal_infos = observation.round_terminal.wins
    scores = observation.public_observation.init_score.tens
    win_terminals = []
    terminal_infos.length.times do |i|  # listとして返している
      terminal_info = terminal_infos[i]
      who = terminal_info.who
      from_who = terminal_info.from_who
      hand = terminal_info.hand.closed_tiles
      win_tile = terminal_info.win_tile
      fu = terminal_info.fu
      fans = terminal_info.fans
      ten = terminal_info.ten
      ten_changes = terminal_info.ten_changes
      yakus = terminal_info.yakus
      yakumans = terminal_info.yakumans
      scores = _get_scores(scores, ten_changes, yakus, who)
      ura_dora_indicators = terminal_info.ura_dora_indicators
      win_terminals.push(Mjai::Action.new({:type=>:hora,:actor=>@absolutepos_id_hash[who],:target=>@absolutepos_id_hash[from_who],:pai=>proto_tile_to_mjai_tile(win_tile),:uradora_markers=>proto_tiles_to_mjai_tiles(ura_dora_indicators),:hora_tehais=>proto_tiles_to_mjai_tiles(hand),
      :yakus=>_to_mjai_yakus(fans, yakus, yakumans),:fu=>fu,:fan=>fans.sum(),:hora_points=>ten,:deltas=>ten_changes,:scores=>scores}))
    end
    return win_terminals
  end

  def _fix_riichi_ten_change(index, who)  # ten_change に直接変更を加えると、関数外でも変更された状態になってしまうため。
    if index == who
      return -1000
    else
      return 0
    end
  end

  def _get_scores(score, ten_changes, yakus, who)  # ダブロンの時スコアを逐次的に変える
    if yakus.include?(1)  # ten_changeは和了者のリーチ棒も考慮に入れる。
      return (0...4).map(){ |i| score[i] + ten_changes[i] + _fix_riichi_ten_change(i, who)}
    end
    return (0...4).map(){ |i| score[i] + ten_changes[i] }
  end

  def _to_mjai_yakus(fans, mjx_yakus, mjx_yakumans)
    mjai_yakus = []
    mjx_yaku_to_mjai_yaku = MjxYakuToMjaiYaku.new()
    if mjx_yakumans.length >0  # 役満の時
      mjx_yakumans.length.times do |i|
        mjx_yakuman_idx = mjx_yakumans[i]  # mjxでは役は数字で定義されている。
        mjai_yakumans = mjx_yaku_to_mjai_yaku.mjai_yaku(mjx_yakuman_idx)
        mjai_yakus.push([mjai_yaku,1])
        return mjai_yaku
      end
    end
    fans.length.times do |i|
      fan = fans[i]
      mjx_yaku_idx = mjx_yakus[i]
      mjai_yaku = mjx_yaku_to_mjai_yaku.mjai_yaku(mjx_yaku_idx)
      if fan>0
        mjai_yakus.push([mjai_yaku, fan])
      end
    end
    return mjai_yakus
  end

  def is_start_kyoku(observation)
    return observation.private_observation.draw_history.length <= 1
  end

  def is_start_game(observation)
    round = observation.public_observation.init_score.round
    honba = observation.public_observation.init_score.honba
    return is_start_kyoku(observation) && round == 0 && honba == 0
  end

  def is_kyoku_over(observation)
    return observation.round_terminal != nil
  end

  def is_game_over(observation)
    return is_kyoku_over(observation) && observation.round_terminal.is_game_over
  end

  def start_kyoku(observation)
    kyoku = observation.public_observation.init_score.round + 1
    if kyoku <= 4
      bakaze = Mjai::Pai.new("E")
    elsif kyoku <= 8
      bakaze = Mjai::Pai.new("S")
    elsif kyoku <= 12
      bakaze = Mjai::Pai.new("W")
    else
      bakaze = Mjai::Pai.new("N")
    end
    honba = observation.public_observation.init_score.honba
    kyotaku = observation.public_observation.init_score.riichi
    oya = observation.public_observation.events[0].who
    dora_marker = proto_tile_to_mjai_tile(observation.public_observation.dora_indicators[0])
    tehai = proto_tiles_to_mjai_tiles(observation.private_observation.init_hand.closed_tiles)
    non_tehai = [Mjai::Pai.new("?")]*13
    player_id = observation.legal_actions[0].who
    tehais = [non_tehai]*4
    tehais[player_id] = tehai
    return Mjai::Action.new({:type=>:start_kyoku, :kyoku=>kyoku,:bakaze=>bakaze, :honba=>honba, :kyotaku=>kyotaku, :oya=>oya, :dora_marker=>dora_marker, :tehais=>tehais})
  end

end