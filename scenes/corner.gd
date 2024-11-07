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
@export var color_scheme:Global.Layer = Global.Layer.Blue: set = set_color_scheme

@onready var border: Polygon2D = $border
@onready var collision: CollisionPolygon2D = $collision
@onready var hatch: Polygon2D = $hatch

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

func set_width(v:float):
  width = v
  _create_geometry()

func set_height(v:float):
  height = v
  _create_geometry()

func set_orientation(v:int):
  orientation = v % 4
  _create_geometry()

func set_color_scheme(v:int):
  color_scheme = v
  _create_geometry()

func _ready() -> void:
  _create_geometry()

func _create_geometry()->void:
  if !border: return
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
