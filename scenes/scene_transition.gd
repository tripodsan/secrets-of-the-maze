extends CanvasLayer

@onready var animation_player:AnimationPlayer = $AnimationPlayer

func change_scene(scene:PackedScene, speed:float = 1.0)->void:
  animation_player.play('fadeout', -1, speed)
  await animation_player.animation_finished
  get_tree().change_scene_to_packed(scene)
  animation_player.play('fadein', -1, speed)
  await animation_player.animation_finished
