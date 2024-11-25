class_name CrystalInfo
extends HBoxContainer

@onready var none: Label = $none
@onready var blue: ColorRect = $blue
@onready var red: ColorRect = $red
@onready var green: ColorRect = $green

var crystals:int = 0

func set_crystals(c:int)->void:
  crystals = c
  none.visible = c == 0
  blue.visible = c & 1
  red.visible = c & 2
  green.visible = c & 4
