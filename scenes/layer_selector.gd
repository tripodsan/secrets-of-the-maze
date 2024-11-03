extends VBoxContainer

@onready var blue: Button = $blue
@onready var red: Button = $red

var _btn_group := ButtonGroup.new()

func _ready() -> void:
  blue.button_group = _btn_group
  red.button_group = _btn_group
  _btn_group.pressed.connect(_on_btn_group_pressed)

func _on_btn_group_pressed(btn:Button)->void:
  Global.layer_selected.emit(Global.Layer.Blue if btn == blue else Global.Layer.Red)
