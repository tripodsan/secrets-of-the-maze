class_name ChromaLayer
extends Node2D

## primary tilemap, use to detect if player can chroma shift
@onready var map:TileMapLayer = $map
@onready var grid:TileMapLayer = $grid
@onready var objects: Node2D = $objects

var active:bool

var game_data:GDLayer

var type:Global.Layer

var navigation_map:RID

func _ready():
  type = Global.get_layer_from_string(name)
  assert(type >= 0)
  visible = false
  # create a navigation map for each layer, so that the enemies have
  # the correct map to operate on
  navigation_map = NavigationServer2D.map_create()
  NavigationServer2D.map_set_cell_size(navigation_map, 1)
  NavigationServer2D.map_set_active(navigation_map, true)
  grid.set_navigation_map(navigation_map)

# set via parent
func set_game_data(layer:GDLayer)->void:
  game_data = layer
  for n:ChromaCrystal in get_tree().get_nodes_in_group('crystal'):
    if is_ancestor_of(n) and layer.has_crystal(n.type):
      # remove cystals already found
      n.queue_free()
  for n:SecretRoom in get_tree().get_nodes_in_group('secret_room'):
    if is_ancestor_of(n):
      if layer.has_secret(n.id):
        n.reveal(true)
      else:
        n.secret_revealed.connect(_on_secret_revealed.bind(n))

func _on_secret_revealed(_immediate:bool, secret:SecretRoom)->void:
  game_data.set_secret(secret.id)

func set_active(value: bool)->void:
  active = value
  Global.activate_layer_in_viewports(type, value)
  Global.enable_collision_in_tree(self, value)
  GameController.activate_layer(self)


## check if ship at global position pos can shift to this layer.
func can_chroma_shift(pos:Vector2)->bool:
  if !visible: return false
  pos = to_local(pos)
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

func get_secret(id:int)->SecretRoom:
  return get_node_or_null('secret_%d' % id)
