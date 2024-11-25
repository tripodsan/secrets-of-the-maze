class_name Minimap
extends Node2D

@onready var maps:Array[TileMapLayer] = [$blue, $red, $green]

@onready var camera_2d: Camera2D = $Camera2D

var cells:Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]

func init_layer(src:TileMapLayer, layer:Global.Layer)->void:
  var dst:TileMapLayer = maps[layer]
  dst.clear()
  for v:Vector2i in src.get_used_cells():
    dst.set_cell(v, 1, cells[layer], 0)

func _ready() -> void:
  GameController.level_loaded.connect(_on_level_loaded)

func _on_level_loaded(level:Level)->void:
  for i in range(3):
    init_layer(level.get_grid(i), i)

func _process(_delta: float) -> void:
  if GameController.player:
    camera_2d.global_position = GameController.player.global_position / 32.0
