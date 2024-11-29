class_name Blast
extends StaticBody2D

# the radius of the blast damage. defines the size of the collision shapre
# outside the radius the blast has no effect. i.e. the damange is < 1.0
var radius:float

var amount:float

var affect_player:bool

var affect_enemy:bool

var ticks:int = 0

func _ready() -> void:
  $collision.shape.radius = radius
  collision_layer = 128 * int(affect_enemy)
  collision_layer |= 256 * int(affect_player)

func get_damage(pos:Vector2)->float:
  var r2:float = pos.distance_squared_to(global_position)
  return remap(r2, 0, radius**2, amount, 0)

func _physics_process(delta: float) -> void:
  ticks += 1
  if ticks > 1:
    collision_layer = 0
  if ticks > 60:
    queue_free()

func _draw()->void:
  for i in range(20):
    var r:float = remap(i, 0, 20, 0, radius)
    var a:float = get_damage(global_position + Vector2(r, 0))
    a /= amount
    draw_circle(Vector2.ZERO, r, Color(a, a, a), false, 1.0, true)
