extends VBoxContainer

@onready var tank: Button = $tank
@onready var ship: Button = $ship

var _btn_group := ButtonGroup.new()

func _ready() -> void:
  tank.button_group = _btn_group
  ship.button_group = _btn_group
  _btn_group.pressed.connect(_on_btn_group_pressed)

func _on_btn_group_pressed(btn:Button)->void:
  Global.engine_type_selected.emit(Global.EngineType.Tank if btn == tank else Global.EngineType.Ship)
