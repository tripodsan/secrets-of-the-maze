class_name LevelMap
extends Node2D

var scn_map_node = preload('res://scenes/level_map/level_map_node.tscn')
var scn_map_conn = preload('res://scenes/level_map/level_map_connector.tscn')
var scn_map_arrow = preload('res://scenes/level_map/level_map_arrow.tscn')

@onready var cursor: LevelMapCursor = $cursor
@onready var nodes: Node2D = $nodes

var selected_level:LevelMapNode

const GRID_SIZE:int = 96

signal level_selected(layer:LevelMapNode)

signal level_accepted(layer:LevelMapNode)

func _ready() -> void:
  rebuild()
  if GameController._current_layer:
    for n in nodes.get_children():
      if n is LevelMapNode && n.gd_layer == GameController._current_layer:
        select(n)
        return
  select(nodes.get_child(0))

func _build_node(layer:GDLayer)->LevelMapNode:
  if !layer: return null
  var level:GDLevel = layer.get_level()
  var lvl:int = level.get_nr()
  var lay:int = layer.idx
  # check if already exist
  var nName = 'level_%d_%s' % [lvl, layer.name]
  var n:LevelMapNode = nodes.get_node_or_null(nName)
  if n: return n
  n = scn_map_node.instantiate()
  n.name = nName
  nodes.add_child(n)
  n.position = Vector2(lvl * GRID_SIZE, -lay * GRID_SIZE)
  n.animation = layer.name if layer.unlocked else '_'
  n.gd_layer = layer
  n.gd_level = level
  n.title = level.get_title()
  n.suffix = '-%s' % layer.name.to_upper()[0]
  n.clicked.connect(_on_map_node_clicked.bind(n))
  if layer.unlocked:
    for i in range(4):
      var dir = LevelMapNode.DIRS[i]
      var nextLayer = GameData.get_layer(lvl + dir.x, lay - dir.y)
      var next = _build_node(nextLayer)
      if next && next.gd_layer.unlocked:
        n.neighbors[i] = next
        next.neighbors[(i + 2)%4] = n
        if i == 1: # draw level connectors
          var a = scn_map_arrow.instantiate()
          nodes.add_child(a)
          a.position = Vector2(lvl * GRID_SIZE + GRID_SIZE / 2, -lay * GRID_SIZE)
          a.animation = layer.name
        elif i == 0: # draw layer connectors
          var c = scn_map_conn.instantiate()
          nodes.add_child(c)
          c.position = Vector2(lvl * GRID_SIZE, -lay * GRID_SIZE - GRID_SIZE / 2)

  return n


func rebuild()->void:
  for n in nodes.get_children():
    nodes.remove_child(n)
    n.queue_free()
  selected_level = null
  _build_node(GameData.get_layer(0, 0))

func _input(event: InputEvent) -> void:
  if Input.is_action_just_pressed('ui_left'):
    select(selected_level.neighbors[3])
  elif Input.is_action_just_pressed('ui_right'):
    select(selected_level.neighbors[1])
  elif Input.is_action_just_pressed('ui_up'):
    select(selected_level.neighbors[0])
  elif Input.is_action_just_pressed('ui_down'):
    select(selected_level.neighbors[2])
  elif Input.is_action_just_pressed('ui_accept'):
    level_accepted.emit(selected_level)

func select(next:LevelMapNode):
  if !next || !next.gd_layer.unlocked: return
  selected_level = next
  cursor.position = next.position
  cursor.set_opening(next.get_nb_bitmask())
  level_selected.emit(next)

func _on_map_node_clicked(n:LevelMapNode)->void:
  select(n)
