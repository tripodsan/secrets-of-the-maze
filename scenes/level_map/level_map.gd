class_name LevelMap
extends Node2D

var scn_map_node = preload('res://scenes/level_map/level_map_node.tscn')
var scn_map_conn = preload('res://scenes/level_map/level_map_connector.tscn')
var scn_map_arrow = preload('res://scenes/level_map/level_map_arrow.tscn')

@onready var cursor: LevelMapCursor = $cursor
@onready var nodes: Node2D = $nodes

var selected_level:LevelMapNode

const GRID_SIZE:int = 96

var ROMAN:Array[String] = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X']

signal level_selected(layer:LevelMapNode)

func _ready() -> void:
  rebuild()

func rebuild()->void:
  for n in nodes.get_children():
    nodes.remove_child(n)
    n.queue_free()
  selected_level = null
  var levels:Node = GameData.get_levels()

  for x in range(levels.get_child_count()):
    var level:GDLevel = levels.get_child(x)
    var layers = level.get_layers()
    var prev:LevelMapNode = null
    for y in range(layers.get_child_count()):
      var layer:GDLayer = layers.get_child(y)
      var n:LevelMapNode = scn_map_node.instantiate()
      n.name = 'level_%d_%s' % [x, layer.name]
      nodes.add_child(n)
      n.position = Vector2(x * GRID_SIZE, -y * GRID_SIZE)
      n.animation = layer.name
      n.gd_layer = layer
      n.gd_level = level
      n.title = 'D%s' % ROMAN[x]
      n.suffix = '-%s' % layer.name.to_upper()[0]
      if prev:
        prev.nb_top = n
        n.nb_bottom = prev
        var c = scn_map_conn.instantiate()
        nodes.add_child(c)
        c.position = Vector2(x * GRID_SIZE, -y * GRID_SIZE + GRID_SIZE / 2)
      if x > 0:
        var left:LevelMapNode = nodes.get_node_or_null('level_%d_%s' % [x - 1, layer.name])
        if left:
          left.nb_right = n
          n.nb_left = left
          var a = scn_map_arrow.instantiate()
          nodes.add_child(a)
          a.position = Vector2(x * GRID_SIZE - GRID_SIZE / 2, -y * GRID_SIZE)
          a.animation = layer.name
      prev = n
      if !layer.unlocked:
        n.animation = '_'
        break

  select(nodes.get_child(0))

func _input(event: InputEvent) -> void:
  if Input.is_action_just_pressed('ui_left'):
    select(selected_level.nb_left)
  elif Input.is_action_just_pressed('ui_right'):
    select(selected_level.nb_right)
  elif Input.is_action_just_pressed('ui_up'):
    select(selected_level.nb_top)
  elif Input.is_action_just_pressed('ui_down'):
    select(selected_level.nb_bottom)

func select(next:LevelMapNode):
  if !next: return
  selected_level = next
  cursor.position = next.position
  cursor.set_opening_by_direction(!!next.nb_top, !!next.nb_right, !!next.nb_bottom, !!next.nb_left)
  level_selected.emit(next)
