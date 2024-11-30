@tool
class_name CubeProjection
extends Node2D

@export_range(1.0, 10, 0.01) var projection_height:float = 2:
  set(v):
    projection_height = v
    queue_redraw()

@export_range(0, TAU, 0.01) var rot_x:float = 0:
  set(v):
    rot_x = v
    queue_redraw()

@export_range(0, 4, 0.01) var rot_dx:float = 1.2:
  set(v):
    rot_dx = v

@export_range(0, TAU, 0.01) var rot_y:float = 0:
  set(v):
    rot_y = v
    queue_redraw()

@export_range(0, 4, 0.01) var rot_dy:float = 1:
  set(v):
    rot_dy = v

@export_range(1, 100, 1) var proj_scale:float = 50.0:
  set(v):
    proj_scale = v
    queue_redraw()

@export var line_color:Color = Color.WHITE:
  set(v):
    line_color = v
    queue_redraw()

@export var line_width:float = 0.5:
  set(v):
    line_width = v
    queue_redraw()

@export var line_aa:bool = false:
  set(v):
    line_aa = v
    queue_redraw()

@export var fill_color:Color = Color.RED:
  set(v):
    fill_color = v
    queue_redraw()

var points:Array[Vector3] = [
  Vector3(-1, -1, -1),
  Vector3( 1, -1, -1),
  Vector3( 1,  1, -1),
  Vector3(-1,  1, -1),
  Vector3(-1, -1,  1),
  Vector3( 1, -1,  1),
  Vector3( 1,  1,  1),
  Vector3(-1,  1,  1)
]

var edges:Array = [
  [0, 1, 2, 3, 0],
  [4, 5, 6, 7, 4],
  [0, 4],
  [1, 5],
  [2, 6],
  [3, 7]
]

func _draw()->void:
  var vs:PackedVector2Array = PackedVector2Array()
  var r:Vector3 = Vector3(0, 0, projection_height)
  vs.resize(points.size())
  for i in range(points.size()):
    var a:Vector3 = points[i].rotated(Vector3.RIGHT, rot_x).rotated(Vector3.UP, rot_y)
    var d:Vector3 = a - r
    var p = r - (d/d.z) * r.z
    vs[i] = Vector2(p.x, p.y) * proj_scale
  var hull:PackedVector2Array = Geometry2D.convex_hull(vs)
  draw_colored_polygon(hull, fill_color)
  for e:Array in edges:
    var lines:PackedVector2Array = []
    for i:int in e:
      lines.append(vs[i])
    draw_polyline(lines, line_color, line_width, line_aa)

func _process(delta:float)->void:
  if rot_dx > 0.0:
    rot_x += delta * rot_dx
  if rot_dy > 0.0:
    rot_y += delta * rot_dy
