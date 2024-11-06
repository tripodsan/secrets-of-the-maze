extends Node

var player:Player

enum Layer { Blue, Red, Green }

signal player_changed()

signal layer_selected(type:Layer)

func set_player(p:Player):
  player = p
  player_changed.emit()
