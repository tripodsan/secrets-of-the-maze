extends StaticBody2D

@onready var collision: CollisionShape2D = $collision

func _notification(what: int) -> void:
  if what == NOTIFICATION_PARENTED:
    var layer:ChromaLayer = get_parent().get_parent() as ChromaLayer
    if layer:
      collision.disabled = !layer.active
