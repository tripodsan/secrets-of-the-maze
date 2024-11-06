class_name ChromaLayer
extends Node2D

@export var layer_idx:int = 1

## primary tilemap, use to detect if player can chroma shift
@onready var map:TileMapLayer = $map

var active:bool

func set_active(value: bool)->void:
  active = value
  get_viewport().set_canvas_cull_mask_bit(layer_idx, value)
  %phasemap.set_canvas_cull_mask_bit(layer_idx, !value)
  process_mode = Node.PROCESS_MODE_INHERIT if active else PROCESS_MODE_DISABLED
  for n in get_children():
    if n is TileMapLayer:
      n.collision_enabled = value

## check if ship at global position pos can shift to this layer.
func can_chroma_shift(pos:Vector2)->bool:
  var p:Vector2i = map.local_to_map(pos)
  var tile:TileData = map.get_cell_tile_data(p)
  #if tile:
    #prints(name, 'tile data', tile.terrain_set)
  #else:
    #prints(name, 'tile data', tile)
  return tile && tile.terrain_set == 1
