# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: mjx/internal/mjx.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("mjx/internal/mjx.proto", :syntax => :proto3) do
    add_message "mjxproto.Score" do
      optional :round, :uint32, 1
      optional :honba, :uint32, 2
      optional :riichi, :uint32, 3
      repeated :tens, :int32, 4
    end
    add_message "mjxproto.Event" do
      optional :type, :enum, 1, "mjxproto.EventType"
      optional :who, :int32, 2
      optional :tile, :uint32, 3
      optional :open, :uint32, 4
    end
    add_message "mjxproto.PublicObservation" do
      optional :game_id, :string, 1
      repeated :player_ids, :string, 2
      optional :init_score, :message, 3, "mjxproto.Score"
      repeated :dora_indicators, :uint32, 4
      repeated :events, :message, 5, "mjxproto.Event"
    end
    add_message "mjxproto.Hand" do
      repeated :closed_tiles, :uint32, 1
      repeated :opens, :uint32, 2
    end
    add_message "mjxproto.PrivateObservation" do
      optional :who, :int32, 1
      optional :init_hand, :message, 2, "mjxproto.Hand"
      repeated :draw_history, :uint32, 3
      optional :curr_hand, :message, 4, "mjxproto.Hand"
    end
    add_message "mjxproto.Observation" do
      optional :who, :int32, 1
      optional :public_observation, :message, 2, "mjxproto.PublicObservation"
      optional :private_observation, :message, 3, "mjxproto.PrivateObservation"
      optional :round_terminal, :message, 4, "mjxproto.RoundTerminal"
      repeated :possible_actions, :message, 5, "mjxproto.Action"
    end
    add_message "mjxproto.Win" do
      optional :who, :int32, 1
      optional :from_who, :int32, 2
      optional :hand, :message, 3, "mjxproto.Hand"
      optional :win_tile, :uint32, 4
      optional :fu, :uint32, 5
      optional :ten, :uint32, 6
      repeated :ten_changes, :int32, 7
      repeated :yakus, :uint32, 8
      repeated :fans, :uint32, 9
      repeated :yakumans, :uint32, 10
      repeated :ura_dora_indicators, :uint32, 11
    end
    add_message "mjxproto.NoWinner" do
      repeated :tenpais, :message, 1, "mjxproto.TenpaiHand"
      repeated :ten_changes, :int32, 2
    end
    add_message "mjxproto.TenpaiHand" do
      optional :who, :int32, 1
      optional :hand, :message, 2, "mjxproto.Hand"
    end
    add_message "mjxproto.RoundTerminal" do
      optional :final_score, :message, 1, "mjxproto.Score"
      repeated :wins, :message, 2, "mjxproto.Win"
      optional :no_winner, :message, 3, "mjxproto.NoWinner"
      optional :is_game_over, :bool, 4
    end
    add_message "mjxproto.State" do
      optional :hidden_state, :message, 1, "mjxproto.HiddenState"
      optional :public_observation, :message, 2, "mjxproto.PublicObservation"
      repeated :private_observations, :message, 3, "mjxproto.PrivateObservation"
      optional :round_terminal, :message, 4, "mjxproto.RoundTerminal"
    end
    add_message "mjxproto.HiddenState" do
      optional :game_seed, :uint64, 1
      repeated :wall, :uint32, 2
      repeated :ura_dora_indicators, :uint32, 3
    end
    add_message "mjxproto.Action" do
      optional :game_id, :string, 1
      optional :who, :int32, 2
      optional :type, :enum, 3, "mjxproto.ActionType"
      optional :discard, :uint32, 4
      optional :open, :uint32, 5
    end
    add_enum "mjxproto.ActionType" do
      value :ACTION_TYPE_DISCARD, 0
      value :ACTION_TYPE_TSUMOGIRI, 1
      value :ACTION_TYPE_RIICHI, 2
      value :ACTION_TYPE_CLOSED_KAN, 3
      value :ACTION_TYPE_ADDED_KAN, 4
      value :ACTION_TYPE_TSUMO, 5
      value :ACTION_TYPE_ABORTIVE_DRAW_NINE_TERMINALS, 6
      value :ACTION_TYPE_CHI, 7
      value :ACTION_TYPE_PON, 8
      value :ACTION_TYPE_OPEN_KAN, 9
      value :ACTION_TYPE_RON, 10
      value :ACTION_TYPE_NO, 11
      value :ACTION_TYPE_DUMMY, 99
    end
    add_enum "mjxproto.EventType" do
      value :EVENT_TYPE_DISCARD, 0
      value :EVENT_TYPE_TSUMOGIRI, 1
      value :EVENT_TYPE_RIICHI, 2
      value :EVENT_TYPE_CLOSED_KAN, 3
      value :EVENT_TYPE_ADDED_KAN, 4
      value :EVENT_TYPE_TSUMO, 5
      value :EVENT_TYPE_ABORTIVE_DRAW_NINE_TERMINALS, 6
      value :EVENT_TYPE_CHI, 7
      value :EVENT_TYPE_PON, 8
      value :EVENT_TYPE_OPEN_KAN, 9
      value :EVENT_TYPE_RON, 10
      value :EVENT_TYPE_DRAW, 12
      value :EVENT_TYPE_RIICHI_SCORE_CHANGE, 13
      value :EVENT_TYPE_NEW_DORA, 14
      value :EVENT_TYPE_ABORTIVE_DRAW_FOUR_RIICHIS, 15
      value :EVENT_TYPE_ABORTIVE_DRAW_THREE_RONS, 16
      value :EVENT_TYPE_ABORTIVE_DRAW_FOUR_KANS, 17
      value :EVENT_TYPE_ABORTIVE_DRAW_FOUR_WINDS, 18
      value :EVENT_TYPE_EXHAUSTIVE_DRAW_NORMAL, 19
      value :EVENT_TYPE_EXHAUSTIVE_DRAW_NAGASHI_MANGAN, 20
    end
  end
end

module Mjxproto
  Score = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("mjxproto.Score").msgclass
  Event = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("mjxproto.Event").msgclass
  PublicObservation = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("mjxproto.PublicObservation").msgclass
  Hand = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("mjxproto.Hand").msgclass
  PrivateObservation = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("mjxproto.PrivateObservation").msgclass
  Observation = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("mjxproto.Observation").msgclass
  Win = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("mjxproto.Win").msgclass
  NoWinner = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("mjxproto.NoWinner").msgclass
  TenpaiHand = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("mjxproto.TenpaiHand").msgclass
  RoundTerminal = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("mjxproto.RoundTerminal").msgclass
  State = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("mjxproto.State").msgclass
  HiddenState = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("mjxproto.HiddenState").msgclass
  Action = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("mjxproto.Action").msgclass
  ActionType = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("mjxproto.ActionType").enummodule
  EventType = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("mjxproto.EventType").enummodule
end