@tool
extends AnimatedSprite2D

@export_flags('top', 'right', 'bottom', 'left') var opening:int = 0: set = set_opening

## cursor configuration. x := frame, y:=rotation
var CONFIGS = [
  Vector2i(0,   0), # 0000
  Vector2i(1,   0), # 0001
  Vector2i(1,  90), # 0010
  Vector2i(2,   0), # 0011
  Vector2i(1, 180), # 0100
  Vector2i(3,  90), # 0101
  Vector2i(2,  90), # 0110
  Vector2i(4,   0), # 0111
  Vector2i(1, 270), # 1000
  Vector2i(2, 270), # 1001
  Vector2i(3,   0), # 1010
  Vector2i(4, 270), # 1011
  Vector2i(2, 180), # 1100
  Vector2i(4, 180), # 1101
  Vector2i(4,  90), # 1110
  Vector2i(5,   0), # 1111
]

func set_opening(v:int):
  opening = v
  frame = CONFIGS[v].x
  rotation_degrees = CONFIGS[v].y
