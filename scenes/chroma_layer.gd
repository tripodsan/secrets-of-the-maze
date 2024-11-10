class_name ChromaLayer
extends Node2D

@export var layer_idx:int = 1

## primary tilemap, use to detect if player can chroma shift
@onready var map:TileMapLayer = $map
@onready var grid:TileMapLayer = $grid

var active:bool

func _ready():
  visible = true

func set_active(value: bool)->void:
  active = value
  Global.activate_layer_in_viewports(layer_idx, value)
  process_mode = Node.PROCESS_MODE_INHERIT if active else PROCESS_MODE_DISABLED
  for n in get_children():
    if n is TileMapLayer:
      n.collision_enabled = value

## check if ship at global position pos can shift to this layer.
func can_chroma_shift(pos:Vector2)->bool:
  var p:Vector2i = map.local_to_map(pos)
  var tile:TileData = map.get_cell_tile_data(p)
  if !tile && grid: tile = grid.get_cell_tile_data(p)
  #if tile:
    #prints(name, 'tile data', tile.terrain_set)
  #else:
    #prints(name, 'tile data', tile)
  return tile && tile.terrain_set == 0

func get_start_position()->Vector2:
  for v in map.get_used_cells():
    var cell = map.get_cell_tile_data(v)
    if cell && cell.get_custom_data("type") == &"start":
      map.set_cell(v, -1)
      return map.map_to_local(v)
  return Vector2.ZERO
