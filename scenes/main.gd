class_name GameScene
extends Node2D

var LEVEL_SCENES:Array[PackedScene] = [
  preload('res://scenes/levels/level_0.tscn'),
  preload('res://scenes/levels/level_1.tscn'),
  preload('res://scenes/levels/level_2.tscn'),
  preload('res://scenes/levels/level_end.tscn')
]

@onready var game: Node2D = $world/game

var _current_level_nr:int = -1

var _current_level:Level = null

func _ready() -> void:
  _current_level = get_node_or_null("world/game/level")
  %phasemap.world_2d = get_viewport().world_2d
  GameController.on_game_scene_loaded(self)

func load_level(layer:GDLayer)->void:
  var nr := layer.get_level().get_nr()
  assert(nr < len(LEVEL_SCENES))
  if _current_level_nr != nr:
    if _current_level:
      game.remove_child(_current_level)
      _current_level.queue_free()
      _current_level = null
    _current_level = LEVEL_SCENES[nr].instantiate()
    game.add_child(_current_level)
    _current_level_nr = nr

# ------------ todo: move to somewhere else ?
func _on_btn_debug_save_pressed() -> void:
  GameData.save_file('save0')
