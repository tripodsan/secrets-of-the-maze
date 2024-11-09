@tool
extends PanelContainer

@onready var button: Button = $container/button
@onready var content: Container = $container/content

@export var open:bool = false: set = set_open

func _ready() -> void:
  button.set_pressed_no_signal(open)
  button.toggled.connect(set_open)

func set_open(v:bool)->void:
  open = v
  if content: content.visible = v
