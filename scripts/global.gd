extends Node

var player:Player

enum Layer { Blue, Red, Green }

enum HitType { Spike }

signal player_changed()

signal player_destroyed(by:HitType)

signal layer_selected(type:Layer)

func set_player(p:Player):
  player = p
  player_changed.emit()
