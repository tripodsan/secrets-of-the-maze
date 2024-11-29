@tool
class_name Oscilator
extends Node2D

@export var preview:bool = false:set = set_preview

@export var amplitude:Vector2 = Vector2(100, 0)

@export var freq:Vector2 = Vector2(0.1, 0)

@export var phase:Vector2 = Vector2(0, 0)

var _targets:Array[Node2D] = []

var _initial_pos:Array[Vector2] = []


func _ready() -> void:
  _store_initial_pos()

func _store_initial_pos():
  _initial_pos = []
  _targets = []
  for t:Node2D in get_children():
    _targets.append(t)
    _initial_pos.append(t.position)

func _reset_initial_pos():
  for i in range(len(_targets)):
    _targets[i].position = _initial_pos[i]

func set_preview(v:bool)->void:
  if Engine.is_editor_hint():
    if preview and not v:
      _reset_initial_pos()
    elif v and not preview:
      _store_initial_pos()
  preview = v

func _process(_delta: float) -> void:
  if preview or not Engine.is_editor_hint():
    var p := Vector2.ZERO
    for i in range(len(_targets)):
      var a:Vector2 = TAU * (p + freq * float(Time.get_ticks_msec()) / 1000.0)
      _targets[i].position = _initial_pos[i] + amplitude * Vector2(cos(a.x), sin(a.y))
      p += phase

func _notification(what: int) -> void:
  if what == Node.NOTIFICATION_EDITOR_PRE_SAVE:
    preview = false
