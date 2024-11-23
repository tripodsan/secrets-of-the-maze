@tool
extends StaticBody2D

const WALL_1 = preload('res://assets/wall1.png')
const WALL_2 = preload('res://assets/wall2.png')
const WALL_3 = preload('res://assets/wall3.png')

@export var reset:bool:
  set(v):
    _create_geometry()

@export var width:int = 4: set = set_width
@export var height:int = 4: set = set_height
@export var orientation:int = 0: set = set_orientation
@export var color_scheme:Global.Layer = Global.Layer.BLUE: set = set_color_scheme
@export var permeable:bool = false
@export var flicker:bool = false

@onready var border: Polygon2D = $border
@onready var collision: CollisionPolygon2D = $collision
@onready var hatch: Polygon2D = $hatch
@onready var sensor: Area2D = $sensor
@onready var sensor_collision: CollisionPolygon2D = $sensor/collision

## propagate the sensors signals
signal body_entered(body: Node2D)
signal body_exited(body: Node2D)

var flicker_time := 0.0
var flicker_on := 0.0
var flicker_off := 0.0
var flicker_count:int = 0

var COLORS = [
  {
    "border": Color("09ccec"),
    "texture": WALL_1
  },
  {
    "border": Color("ff881a"),
    "texture": WALL_2
  },
  {
    "border": Color("9aeb00"),
    "texture": WALL_3
  },
]

const border_width = 16
const grid_size = 64
const detail = 20

func set_width(v:int):
  width = v
  _create_geometry()

func set_height(v:int):
  height = v
  _create_geometry()

func set_orientation(v:int):
  orientation = v % 4
  _create_geometry()

func set_color_scheme(v:Global.Layer):
  color_scheme = v
  _create_geometry()

func _ready() -> void:
  _create_geometry()
  if !Engine.is_editor_hint():
    if permeable:
      collision_layer = 0
    sensor.body_entered.connect(body_entered.emit)
    sensor.body_exited.connect(body_exited.emit)
    if flicker:
      update_flicker()

func update_flicker():
  flicker_time = 0
  flicker_on = randf_range(1.0, 5.0)
  flicker_off = flicker_on + randf_range(0.1, 0.3)


func _process(delta)->void:
  if Engine.is_editor_hint(): return
  if !flicker: return
  flicker_time += delta
  if flicker_time > flicker_on:
    modulate.a = 0.1 if (flicker_count >> 2) % 2 else 1.0
    flicker_count += 1
    if flicker_time > flicker_off:
      modulate.a = 1.0
      update_flicker()

func _create_geometry()->void:
  if !border: return
  if width > 0 && height > 0:
    _create_arc()
  else:
    _create_line()

func _create_line()->void:
  assert(width == 0 || height == 0)
  var vs := PackedVector2Array()
  var dx:float = width * grid_size
  var dy:float = height * grid_size
  vs.append(Vector2(0,0))
  if width == 0:
    vs.append(Vector2(0, dy))
    vs.append(Vector2(border_width, dy))
    vs.append(Vector2(border_width, 0))
  else:
    vs.append(Vector2(dx, 0))
    vs.append(Vector2(dx, -border_width))
    vs.append(Vector2(0, -border_width))
  border.polygon = vs
  border.rotation_degrees = orientation * 90
  collision.polygon = vs
  collision.rotation_degrees = orientation * 90
  sensor_collision.polygon = vs
  sensor_collision.rotation_degrees = orientation * 90
  border.color = COLORS[color_scheme].border

  # create hatch
  vs = PackedVector2Array()
  vs.append(Vector2(0,0))
  if width == 0:
    vs.append(Vector2(-grid_size, 0))
    vs.append(Vector2(-grid_size, dy))
    vs.append(Vector2(0, dy))
  else:
    vs.append(Vector2(0, grid_size))
    vs.append(Vector2(dx, grid_size))
    vs.append(Vector2(dx, 0))
  hatch.polygon = vs
  hatch.rotation_degrees = orientation * 90
  hatch.texture = COLORS[color_scheme].texture
  hatch.texture_rotation = orientation * PI/2


func _create_arc()->void:
  var vs := PackedVector2Array()
  vs.append(Vector2(0,0))
  var cx:float = width * grid_size
  var cy:float = 0
  var dx:float = width * grid_size
  var dy:float = height * grid_size
  # outer segment
  for a:float in range(0, detail):
    a = a * PI/(2*detail)
    vs.append(Vector2(-cos(a) * dx + cx, sin(a) * dy + cy))
  vs.append(Vector2(dx, dy))
  dx -= border_width
  dy -= border_width
  for a:float in range(detail, 0, -1):
    a = a * PI/(2*detail)
    vs.append(Vector2(-cos(a) * dx + cx, sin(a) * dy + cy))
  vs.append(Vector2(border_width, 0))
  border.polygon = vs
  border.rotation_degrees = orientation * 90
  collision.polygon = vs
  collision.rotation_degrees = orientation * 90
  sensor_collision.polygon = vs
  sensor_collision.rotation_degrees = orientation * 90
  border.color = COLORS[color_scheme].border

  # create hatch
  vs = PackedVector2Array()
  vs.append(Vector2(0,0))
  vs.append(Vector2(-grid_size,0))
  dx = (width + 1) * grid_size
  dy = (height + 1) * grid_size
  for a:float in range(0, detail):
    a = a * PI/(2*detail)
    var v = Vector2(-cos(a) * dx + cx, sin(a) * dy + cy)
    vs.append(v)
  vs.append(Vector2(dx - grid_size, dy))
  dx -= grid_size
  dy -= grid_size
  for a:float in range(detail, 0, -1):
    a = a * PI/(2*detail)
    var v = Vector2(-cos(a) * dx + cx, sin(a) * dy + cy)
    vs.append(v)

  hatch.polygon = vs
  hatch.rotation_degrees = orientation * 90
  hatch.texture = COLORS[color_scheme].texture
  hatch.texture_rotation = orientation * PI/2
