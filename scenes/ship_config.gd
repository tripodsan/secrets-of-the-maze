extends GridContainer


func _ready() -> void:
  #visible = true
  if Global.player:
    init()
  else:
    Global.player_changed.connect(init)

func init()->void:
  for node in get_children():
    if node is SpinBox:
      node.value = Global.player.get(node.name)
      node.value_changed.connect(_on_value_changed.bind(node.name))

func _on_value_changed(value:float, prop_name:String)->void:
  Global.player.set(prop_name, value)

func _input(_event: InputEvent) -> void:
  if Input.is_action_just_pressed('ui_accept'):
    get_viewport().gui_release_focus()
