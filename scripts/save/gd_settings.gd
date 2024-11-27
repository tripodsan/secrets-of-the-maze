class_name GDSettings
extends GDSerializable

@export var player_name:String = "POD"

@export var maze_scale:float = 0.5

var SCALE_NAMES = {
  0.5: 'Small',
  0.75:'Normal',
  1.0: 'Large'
}

# not a real toggle...
func toggle_maze_scale()->void:
  maze_scale += 0.25
  if maze_scale > 1.0:
    maze_scale = 0.5

func get_maze_scale_name()->String:
  return SCALE_NAMES[maze_scale]
