extends Node

# see https://github.com/godotengine/godot-proposals/issues/2411
## Maximum negative 64-bit signed integer number. Its positive cannot be represented in 64 bits.
## [br]0x8000000000000000
const INT64_NEGATIVE_LIMIT: int = -9223372036854775808
## Maximum positive 64-bit signed integer number. Use a minus to obtain its negative.
## [br]0x7FFFFFFFFFFFFFFF
const INT64_MAX: int = 9223372036854775807


var player:Player

var _phasemap:SubViewport

enum Layer { NONE = -1, BLUE, RED, GREEN }

func get_layer_from_string(s):
  return Layer.get(str(s).to_upper())

enum HitType { Spike }

signal player_changed()

signal player_destroyed(by:HitType)

signal layer_selected(type:Layer)

signal layer_activated(type:Layer)

signal level_loaded(level:Level)

signal supernova

func select_layer():
  pass

func set_player(p:Player):
  player = p
  player_changed.emit()

func get_tile_type(map, rid)->StringName:
  if map is TileMapLayer:
    var pos:Vector2i = map.get_coords_for_body_rid(rid)
    var data:TileData = map.get_cell_tile_data(pos)
    if data:
      return data.get_custom_data("type")
  return &""

func activate_layer_in_viewports(layer_idx:int, enabled:bool)->void:
  get_viewport().set_canvas_cull_mask_bit(layer_idx, enabled)
  _phasemap.set_canvas_cull_mask_bit(layer_idx, !enabled)
