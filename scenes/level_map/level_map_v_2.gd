@tool
class_name LevelMapV2
extends Control

@onready var questionmark: Label = %questionmark

var COLORS = [
  {
    "border": Color("09ccec"),
    "fill": Color("096aec")
  },
  {
    "border": Color("ff881a"),
    "fill": Color('a23000')
  },
  {
    "border": Color("9aeb00"),
    "fill": Color('386900')
  },
]

@export_range(10, 50, 1.0, "or_greater") var layer_radius:float = 32:
  set(v):
    layer_radius = v
    queue_redraw()

@export var ring_width:float = 5.0:
  set(v):
    ring_width = v
    queue_redraw()

@export var ring_color:Color = Color.AZURE:
  set(v):
    ring_color = v
    queue_redraw()

@export var layer_disabled_dim:float = 0.5:
  set(v):
    layer_disabled_dim = v
    queue_redraw()

@export var arc_width:float = 10.0:
  set(v):
    arc_width = v
    queue_redraw()

@export var connector_dash:float = 20.0:
  set(v):
    connector_dash = v
    queue_redraw()

@export var arc_color:Color = Color.AZURE:
  set(v):
    arc_color = v
    queue_redraw()

@export var select_color:Color = Color.WHITE:
  set(v):
    select_color = v
    queue_redraw()

@export var debug:bool = false:
  set(v):
    debug = v
    queue_redraw()

@export_flags("blue_red", "red_green", "green_blue") var arcs_debug_0:int = 0:
  set(v):
    arcs_debug_0 = v
    queue_redraw()
@export_flags("blue_red", "red_green", "green_blue") var arcs_debug_1:int = 0:
  set(v):
    arcs_debug_1 = v
    queue_redraw()
@export_flags("blue", "red", "green") var layer_debug:int = 0:
  set(v):
    layer_debug = v
    queue_redraw()
@export_flags("0_1", "1_2", "2_3") var level_debug:int = 0:
  set(v):
    level_debug = v
    queue_redraw()

@export var end_debug:bool = false:
  set(v):
    end_debug = v
    queue_redraw()

signal level_selected(layer:GDLayer)

signal level_accepted(layer:GDLayer)

const MAX_LEVELS = Vector2i(3, 3)

var selected:Vector2i = Vector2.ZERO

var selected_level:GDLayer
var selected_node:LevelNode

class LevelNode extends RefCounted:
  var pos:Vector2
  var lay:Vector2i

  func _init(pos:Vector2, lay:Vector2i):
    self.pos = pos
    self.lay = lay

var level_nodes:Array[LevelNode] = []

func _ready()->void:
  if Engine.is_editor_hint():
    return
  selected_level = GameController._current_layer
  if !selected_level:
    selected_level = GameData.get_layer(0, 0)
  selected = Vector2i(selected_level.get_level().get_nr(), selected_level.type)
  level_selected.emit(selected_level)

func _get_minimum_size():
  return Vector2(100, 100)

func _input(_event: InputEvent) -> void:
  #
  # 225\ /-45 / 315
  #     X
  # 135/ \45
  if Input.is_action_just_pressed('ui_left'):
    select(Vector2i(91, 269))
    #select(Vector2i(135, 225))
  elif Input.is_action_just_pressed('ui_right'):
    select(Vector2i(-91, 89))
    #select(Vector2i(-45, 45))
  elif Input.is_action_just_pressed('ui_up'):
    select(Vector2i(181, 359))
    #select(Vector2i(225, 315))
  elif Input.is_action_just_pressed('ui_down'):
    select(Vector2i(1, 179))
    #select(Vector2i(45, 135))
  elif Input.is_action_just_pressed('ui_accept'):
    SoundController.play_sfx('ui_select')
    level_accepted.emit(selected_level)

func select(sector:Vector2i):
  # traverse over all nodes in the sector and pick the closest one
  var best_node:LevelNode = null
  var best_dist:float = INF
  for n:LevelNode in level_nodes:
    if n == selected_node: continue
    var a = rad_to_deg(selected_node.pos.angle_to_point(n.pos))
    if a < -1: a = 360 + a
    if a >= sector.x && a <= sector.y:
      var d = selected_node.pos.distance_squared_to(n.pos)
      if d < best_dist:
        best_dist = d
        best_node = n
  if best_node:
    SoundController.play_sfx('ui_change', false, -7.0)
    var next_level:GDLayer = GameData.get_layer(best_node.lay.x, best_node.lay.y)
    selected = best_node.lay
    selected_level = next_level
    selected_node = best_node
    level_selected.emit(selected_level)
    queue_redraw()

func _draw() -> void:
  var center:Vector2 = size/2
  var show_end:bool = end_debug || !Engine.is_editor_hint() && GameData.get_level(3).unlocked
  level_nodes = []
  selected_node = null
  for lvl in range(3):
    var r = remap(lvl, 0, 3, min(size.x, size.y) - layer_radius, 0) / 2.0
    var r_next = remap(lvl + 1, 0, 3, min(size.x, size.y) - layer_radius, 0) / 2.0
    draw_circle(center, r, ring_color, false, ring_width, true)

    # draw connector arcs first
    for lay in range(3):
      var a0 = PI - TAU / 3.0 * float(lay)
      var cl = Vector2(r, 0).rotated(a0) + center

      # layer connector
      var enabled_0 = arcs_debug_0 & Global.LAYER_MASK[lay] > 0
      var enabled_1 = arcs_debug_1 & Global.LAYER_MASK[lay] > 0
      if !debug && !Engine.is_editor_hint():
        var next_lay = (lay + 1) % 3
        enabled_0 = GameData.get_layer(lvl, lay).has_crystal(next_lay)
        enabled_1 = GameData.get_layer(lvl, next_lay).has_crystal(lay)

      if enabled_0:
        draw_arc(center, r, a0, a0 - TAU / 6.0, 20, arc_color, arc_width, true)
      if enabled_1:
        draw_arc(center, r, a0 - TAU / 6.0, a0 - TAU / 3.0, 20, arc_color, arc_width, true)

      # level connector
      var enabled = level_debug & Global.LAYER_MASK[lvl] > 0
      if !debug && !Engine.is_editor_hint():
        var next_lvl_lay = GameData.get_layer(lvl + 1, lay)
        enabled = next_lvl_lay && next_lvl_lay.unlocked || lvl == 2 && show_end
      if enabled:
        var cl_next = Vector2(r_next, 0).rotated(a0) + center
        draw_dashed_line(cl, cl_next, arc_color, arc_width, connector_dash, true, true)

    for lay in range(3):
      var a0 = PI - TAU / 3.0 * float(lay)
      var cl = Vector2(r, 0).rotated(a0) + center
      var color:Color = COLORS[lay].fill

      var enabled = layer_debug & Global.LAYER_MASK[lay] != 0
      if !debug && !Engine.is_editor_hint():
        enabled = GameData.get_layer(lvl, lay).unlocked

      if enabled:
        draw_circle(cl, layer_radius, color, true, -1, true)
        draw_circle(cl, layer_radius + arc_width / 2.0, arc_color, false, arc_width, true)
        var level_node = LevelNode.new(cl, Vector2i(lvl, lay));
        level_nodes.append(level_node)
        if selected.x == lvl && selected.y == lay:
          selected_node = level_node
          var pulse = sin(Time.get_ticks_msec() / 200.0) * 3.0
          draw_circle(cl, layer_radius + arc_width + pulse, select_color, false, arc_width + pulse/2, true)

      else:
        draw_circle(cl, layer_radius, color.darkened(layer_disabled_dim), true, -1, true)
        draw_circle(cl, layer_radius + ring_width / 2.0, ring_color, false, ring_width, true)

    if show_end:
      draw_circle(center, layer_radius, arc_color, true, -1, true)
      draw_circle(center, layer_radius + arc_width / 2.0, arc_color, false, arc_width, true)
      questionmark.visible = false
      if selected.x == 3:
        var pulse = sin(Time.get_ticks_msec() / 200.0) * 3.0
        draw_circle(center, layer_radius + arc_width + pulse, select_color, false, arc_width + pulse/2, true)

    else:
      questionmark.visible = true


func _process(delta: float) -> void:
  queue_redraw()
