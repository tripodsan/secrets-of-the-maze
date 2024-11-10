extends SubViewport

func _ready() -> void:
  Global._phasemap = self

func _process(delta: float) -> void:
  canvas_transform = $'/root'.get_viewport().canvas_transform
