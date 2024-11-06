extends GridContainer


func _ready() -> void:
  visible = true
  if Global.player:
    init()
  else:
    Global.player_changed.connect(init)

func init()->void:
  for node in get_children():
    if node is SpinBox:
      node.value = Global.player.get(node.name)
      node.value_changed.connect(_on_value_changed.bind(node.name))

func _on_value_changed(value:float, name:String)->void:
  Global.player.set(name, value)
