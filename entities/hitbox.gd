class_name HitBox
extends Area2D

@export var is_enemy:bool = false

@onready var collision: CollisionShape2D = $collision

func _ready() -> void:
  body_entered.connect(_on_body_entered)

func set_disabled(value:bool)->void:
  collision.set_deferred('disabled', value)

func _on_body_entered(body: Node2D) -> void:
  prints('hitbox body entered:', body)
  var blast:Blast = body as Blast
  if blast && ((is_enemy && blast.affect_enemy) || (!is_enemy && blast.affect_player)):
    var dmg:float = blast.get_damage(get_parent().global_position)
    get_parent().apply_damage(dmg, body)
    return
  var dmg = 50.0
  if body.has_method('get_damage'):
    dmg = body.get_damage()

  get_parent().apply_damage(dmg, body)

## applies external damange, eg from laser
func apply_damage(amount:float, source:Node2D)->void:
  get_parent().apply_damage(amount, source)
