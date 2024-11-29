extends StaticBody2D

@onready var collision: CollisionShape2D = $collision

func _notification(what: int) -> void:
  if what == NOTIFICATION_PARENTED:
    collision.disabled = !ChromaLayer.is_in_active_layer(self)
