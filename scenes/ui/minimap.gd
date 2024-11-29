extends SubViewport

func _ready() -> void:
  Global._phasemap = self

func _process(_delta: float) -> void:
  canvas_transform = $'/root'.get_viewport().canvas_transform
