class_name ChromaLayer
extends Node2D

@export var layer_idx:int = 1

## primary tilemap, use to detect if player can chroma shift
@onready var map:TileMapLayer = $map
@onready var grid:TileMapLayer = $grid
@onready var objects: Node2D = $objects

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
  prints('check chroma shift at', pos)
  var p:Vector2i = map.local_to_map(pos)
  var tile:TileData = grid.get_cell_tile_data(p)
  if tile:
    prints(name, 'tile data', tile.terrain_set)
  else:
    prints(name, 'tile data', tile)
  return tile && tile.terrain_set == 0

func get_portal(id:int)->Portal:
  return objects.get_node_or_null('portal_%d' % id)
