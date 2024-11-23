@tool
extends Node2D

@export var animate:bool = false

@export var speed:float = 0.1

var points:PackedVector2Array = PackedVector2Array()

var phase:float = 0:
  set(v):
    phase = v
    queue_redraw()

@export var size:float = 60:
  set(v):
    size = v
    queue_redraw()

@export var pattern:Array[Vector2] = [
  Vector2(0.5, 1.0),
  Vector2(1.0, 0.5)
]:
  set(v):
    pattern = v
    queue_redraw()

@export var color:Color = Color.WHITE:
  set(v):
    color = v
    queue_redraw()

@export var sides:int = 12:
  set(v):
    sides = v
    queue_redraw()

func _draw()->void:
  points.resize(sides)
  for i:int in range(sides):
    var a := remap(i, 0, sides, 0, TAU)
    var f:Vector2 = pattern[i % len(pattern)]
    var radius:float = size * remap(sin(phase * TAU), -1, 1, f.x, f.y)
    var x := cos(a) * radius
    var y := sin(a) * radius
    points[i] = Vector2(x, y)
  draw_colored_polygon(points, color)

func _process(_delta:float)->void:
  if animate:
    # use Engine time to synchronize animation
    phase = fmod(speed * float(Time.get_ticks_msec()) / 1000.0, 1)
    queue_redraw()
