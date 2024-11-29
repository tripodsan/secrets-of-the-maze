@tool
class_name MultiTextureRect
extends TextureRect

@export var region_size:Vector2 = Vector2(192, 96):
  set(v):
    region_size = v
    update_atlas()

@export var region:int = 0:
  set(v):
    region = v
    update_atlas()

func update_atlas()->void:
  texture.region = Rect2(Vector2(region_size.x * region, 0), region_size)
