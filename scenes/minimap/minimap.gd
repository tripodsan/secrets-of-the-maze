class_name Minimap
extends Node2D

@onready var maps:Array[TileMapLayer] = [$blue, $red, $green]

@onready var camera_2d: Camera2D = $Camera2D

var cells:Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]

func _ready() -> void:
  GameController.level_loaded.connect(_on_level_loaded)
  GameController.layer_activated.connect(_on_layer_activated)

func _on_level_loaded(level:Level)->void:
  level.state_changed.connect(_on_level_state_changed.bind(level))
  for layer in range(3):
    var src:TileMapLayer = level.get_grid(layer)
    var dst:TileMapLayer = maps[layer]
    dst.clear()
    for v:Vector2i in src.get_used_cells():
      dst.set_cell(v, 1, cells[layer], 0)

func _on_layer_activated(layer:ChromaLayer)->void:
  for i in range(3):
    maps[i].z_index = 3 if layer.type == i else i
    maps[i].visible = layer.game_data.has_crystal(i)
  maps[layer.type].visible = true

func _on_level_state_changed(level:Level)->void:
  if level.state == Level.State.STARTING:
    _on_layer_activated(level._start_layer)

func _process(_delta: float) -> void:
  if GameController.player:
    camera_2d.global_position = GameController.player.global_position / 32.0 / GameData.get_settings().maze_scale
