@tool
class_name LevelMapV2
extends Control

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

@export_flags("blue_red", "red_green", "green_blue") var arcs_debug:int = 0:
  set(v):
    arcs_debug = v
    queue_redraw()
@export_flags("blue", "red", "green") var layer_debug:int = 0:
  set(v):
    layer_debug = v
    queue_redraw()
@export_flags("0_1", "1_2", "2_3") var level_debug:int = 0:
  set(v):
    level_debug = v
    queue_redraw()

signal level_selected(layer:GDLayer)

signal level_accepted(layer:GDLayer)

const MAX_LEVELS = Vector2i(3, 3)

var selected:Vector2i = Vector2.ZERO

var selected_level:GDLayer

func _ready()->void:
  if Engine.is_editor_hint():
    return
  selected_level = GameData.get_layer(0, 0)
  level_selected.emit(selected_level)


func _get_minimum_size():
  return Vector2(100, 100)

func _input(_event: InputEvent) -> void:
  var sign = 1 if selected.y == 0 else -1
  if Input.is_action_just_pressed('ui_left'):
    select(selected + Vector2i.LEFT * sign)
  elif Input.is_action_just_pressed('ui_right'):
    select(selected + Vector2i.RIGHT * sign)
  elif Input.is_action_just_pressed('ui_up'):
    select((selected + Vector2i.UP * sign + MAX_LEVELS) % MAX_LEVELS)
  elif Input.is_action_just_pressed('ui_down'):
    select((selected + Vector2i.DOWN * sign + MAX_LEVELS) % MAX_LEVELS)
  elif Input.is_action_just_pressed('ui_accept'):
    pass #/level_accepted.emit(selected_level)

func select(next:Vector2i):
  if next.x < 0 || next.x > 2: return
  selected = next
  selected_level = GameData.get_layer(selected.x, selected.y)
  level_selected.emit(selected_level)
  queue_redraw()


func _draw() -> void:
  #draw_rect(Rect2(Vector2.ZERO, size), Color.RED)
  var center:Vector2 = size/2
  for lvl in range(3):
    var r = remap(lvl, 0, 3, min(size.x, size.y) - layer_radius, 0) / 2.0
    var r_next = remap(lvl + 1, 0, 3, min(size.x, size.y) - layer_radius, 0) / 2.0
    draw_circle(center, r, ring_color, false, ring_width, true)

    # draw connector arcs first
    for lay in range(3):
      var a0 = PI - TAU / 3.0 * float(lay)
      var cl = Vector2(r, 0).rotated(a0) + center

      # layer connector
      var enabled = arcs_debug & Global.LAYER_MASK[lay] > 0
      if !debug && !Engine.is_editor_hint():
        var next_lay = (lay + 1) % 3
        enabled = GameData.get_layer(lvl, lay).has_crystal(next_lay)
        # todo: draw directional arc
        enabled = enabled || GameData.get_layer(lvl, next_lay).has_crystal(lay)

      if enabled:
        var a1 = PI - TAU / 3.0 * float(lay + 1)
        draw_arc(center, r, a0, a1, 20, arc_color, arc_width, true)

      # level connector
      if level_debug & Global.LAYER_MASK[lvl] > 0:
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
      else:
        draw_circle(cl, layer_radius, color.darkened(layer_disabled_dim), true, -1, true)
        draw_circle(cl, layer_radius + ring_width / 2.0, ring_color, false, ring_width, true)
      if selected.x == lvl && selected.y == lay:
        var pulse = sin(Time.get_ticks_msec() / 200.0) * 3.0
        draw_circle(cl, layer_radius + arc_width + pulse, select_color, false, arc_width + pulse/2, true)

func _process(delta: float) -> void:
  queue_redraw()
