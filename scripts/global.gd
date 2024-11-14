extends Node

var player:Player

var _phasemap:SubViewport

enum Layer { Blue, Red, Green }

enum HitType { Spike, Mine}

signal player_changed()

signal player_destroyed(by:HitType)

signal layer_selected(type:Layer)

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
