extends Node2D

#func _ready()->void:
  #GameController.maze_scale_changed.connect(_on_maze_scale_changed)
  #_on_maze_scale_changed()
#
#func _on_maze_scale_changed()->void:
  #var s = Vector2.ONE * GameData.get_settings().maze_scale
  #$Fireballs.scale = s
  #for n:Node2D in get_children():
    #n.scale = s


func fire() -> void:
  $Sparks.emitting = true
  $Fireballs.emitting = true
  $Smoke.emitting = true
  $InitialFlash.emitting = true
