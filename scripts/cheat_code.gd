class_name Cheatcode
extends Node

@export var code:String

@export var description:String

var matched:int = 0

var is_unlocked:bool = false

signal unlocked()

func _ready() -> void:
  matched = 0
  is_unlocked = false

func _input(event: InputEvent) -> void:
  var evt:InputEventKey = event as InputEventKey
  if evt && evt.is_pressed():
    if evt.unicode == code.unicode_at(matched):
      matched += 1
      if matched == len(code):
        prints("cheat '%s' unlocked" % code)
        is_unlocked = true
        unlocked.emit()
        matched = 0
    else:
       matched = 0
