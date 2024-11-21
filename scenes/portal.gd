@tool
class_name Portal
extends Node2D

enum Shape {Ring, Triangle, Star}

var _colors:Array[GradientTexture1D] = [
  preload('res://scenes/gradient_texture_green_to_red.tres'), # blue layer
  preload('res://scenes/gradient_texture_blue_to_green.tres'), # red layer
  preload('res://scenes/gradient_texture_blue_to_red.tres') # green layer
]

@export var debug_draw:bool = false:
  set(v):
    debug_draw = v
    queue_redraw()

@export var a:= 100.0:
  set(v):
    a=v
    queue_redraw()

@export var k := -0.1:
  set(v):
    k=v
    queue_redraw()

@export_range(0.0, 100.0, 0.1) var ph_max : = 50.0:
  set(v):
    ph_max=v
    queue_redraw()

@export_range(-100.0, 100.0, 0.1) var ph_min : = -50.0:
  set(v):
    ph_min=v
    queue_redraw()

@export_range(0.0, TAU, 0.1) var ph_off : = 0.0:
  set(v):
    ph_off=v
    queue_redraw()

@export var ph_scale:float = 1.0:
  set(v):
    ph_scale=v
    queue_redraw()

@onready var marker: Marker2D = $marker
var marker_pos:Vector2

@export var shape:Shape = Shape.Ring:set = set_shape

@export var layer:Global.Layer = Global.Layer.BLUE:set = set_layer

@export var enabled:bool = true:
  set(v):
    enabled = v
    visible = v
    process_mode = PROCESS_MODE_INHERIT if v else PROCESS_MODE_DISABLED

func _ready() -> void:
  if !Engine.is_editor_hint():
    $helper_arrow.queue_free()
  set_shape(shape)
  set_layer(layer)

func set_shape(s:Shape)->void:
  shape = s
  for n in get_children():
    if n is GPUParticles2D:
      n.emitting = false
      n.visible = false
  if shape < get_child_count():
    get_child(shape).visible = true
    get_child(shape).restart()

func set_layer(l)->void:
  layer = l
  if shape < get_child_count():
    get_child(shape).process_material.color_ramp = _colors[layer]
    get_child(shape).restart()

func _draw()->void:
  if debug_draw:
    var vs:PackedVector2Array = []
    vs.resize(100)
    for i in range(len(vs)):
      vs[i] = get_spiral_pos(float(i) / len(vs)).rotated(-rotation)
    draw_polyline(vs, Color.WHITE)

func init_spiral(g_pos:Vector2)->void:
    var d:Vector2 = g_pos - global_position
    #a = d.length()
    var ph := (1.0 / k) * log(d.length() / a)
    ph_off = ph_scale * d.angle() - ph
    ph_min = ph

func get_spiral_pos(t:float)->Vector2:
  var ph := lerpf(ph_min, ph_max, t)
  var r := a * exp(k * ph)
  return Vector2.RIGHT.rotated((ph + ph_off) * ph_scale) * r

func _process(delta)->void:
  if Engine.is_editor_hint():
    if marker.global_position != marker_pos:
      marker_pos = marker.global_position
      init_spiral(marker_pos)

func reset()->void:
  set_shape(shape)

func _on_detector_body_entered(body: Node2D) -> void:
  prints('on body entrered portal', self, body)
  if body is Player:
    var player:Player = body
    player.portal_enter(self)
    get_child(shape).emitting = false
