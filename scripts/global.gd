extends Node

# see https://github.com/godotengine/godot-proposals/issues/2411
## Maximum negative 64-bit signed integer number. Its positive cannot be represented in 64 bits.
## [br]0x8000000000000000
const INT64_NEGATIVE_LIMIT: int = -9223372036854775808
## Maximum positive 64-bit signed integer number. Use a minus to obtain its negative.
## [br]0x7FFFFFFFFFFFFFFF
const INT64_MAX: int = 9223372036854775807

var _phasemap:SubViewport

enum Layer { NONE = -1, BLUE, RED, GREEN }

const LAYER_MASK = [1, 2, 4]

func get_layer_from_string(s):
  return Layer.get(str(s).to_upper())

func get_layer_cull_mask_bit(layer:Layer)->int:
  return layer + 1

## recursively walks up the tree until it finds the chromlayer
func get_chroma_layer(node:Node2D)->ChromaLayer:
  if node is ChromaLayer:
    return node
  return get_chroma_layer(node.get_parent())

enum HitType { Spike, Mine, Ship }

@warning_ignore('unused_signal')
signal layer_selected(layer:ChromaLayer)

@warning_ignore('unused_signal')
signal supernova

func get_tile_type(map, rid)->StringName:
  if map is TileMapLayer:
    var pos:Vector2i = map.get_coords_for_body_rid(rid)
    var data:TileData = map.get_cell_tile_data(pos)
    if data:
      return data.get_custom_data("type")
  return &""

func activate_layer_in_viewports(layer:Layer, enabled:bool)->void:
  var bit = get_layer_cull_mask_bit(layer)
  get_viewport().set_canvas_cull_mask_bit(bit, enabled)
  _phasemap.set_canvas_cull_mask_bit(bit, !enabled)

func enable_collision_in_tree(parent:Node2D, enabled:bool)->void:
  for n in parent.get_children():
    if n is TileMapLayer:
      n.collision_enabled = enabled
    elif n is CollisionShape2D or n is CollisionPolygon2D:
      n.disabled = !enabled
    elif n is Node2D:
      enable_collision_in_tree(n, enabled)

func format_time(msec:float)->String:
  var hsec:int = msec / 10
  var sec:int = hsec / 100
  return '%02d:%02d.%02d' % [sec / 60, sec % 60, hsec % 100]

func fade(item:CanvasItem, from:float = 0.0, to:float = 1.0, time:float = 0.5):
  item.modulate.a = from
  var tween:Tween = create_tween()
  tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
  tween.tween_property(item, 'modulate:a', to, time)
  await tween.finished

func change_volume(player:AudioStreamPlayer, db:float, time:float = 0.5, autostop:bool = false)->void:
  var start:float = db_to_linear(player.volume_db)
  var end:float = db_to_linear(db)
  var tween = create_tween()
  tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
  tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
  tween.tween_method(func(v:float): player.volume_db = linear_to_db(v), start, end, time)
  await tween.finished
  if autostop:
    player.stop()
