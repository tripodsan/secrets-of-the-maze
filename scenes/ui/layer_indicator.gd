@tool
class_name LayerIndicator
extends MarginContainer

@onready var layer: MultiTextureRect = $layer

@onready var blue_cystals_red: MultiTextureRect = $blue_cystals_red
@onready var blue_cystals_green: MultiTextureRect = $blue_cystals_green
@onready var red_cystals_green: MultiTextureRect = $red_cystals_green
@onready var red_cystals_blue: MultiTextureRect = $red_cystals_blue
@onready var green_cystals_blue: MultiTextureRect = $green_cystals_blue
@onready var green_cystals_red: MultiTextureRect = $green_cystals_red

@export var type:Global.Layer = Global.Layer.BLUE:
  set(v):
    type = v
    update_layer()

@export var crystals:Array[int] = [0, 0, 0]:
  set(v):
    crystals = v
    update_layer()

func _ready()->void:
  if Engine.is_editor_hint():
    return
  GameController.layer_activated.connect(_on_layer_activated)
  GameController.level_loaded.connect(_on_level_loaded)


func _on_layer_activated(l:ChromaLayer)->void:
  type = l.type

func _on_level_loaded(level:Level)->void:
  level.chrystals_changed.connect(_on_crystals_changed.bind(level))
  _on_crystals_changed(level)

func _on_crystals_changed(level:Level)->void:
  var cs:Array[int] = [0, 0, 0]
  for layer:ChromaLayer in level._layers:
    cs[layer.type] = layer.game_data.crystals
  for crystal in level._picked_up_crystals:
    cs[crystal.source] |= Global.LAYER_MASK[crystal.type]
  crystals = cs

func update_layer():
  layer.region = type
  blue_cystals_red.visible = crystals[0] & Global.LAYER_MASK[1] != 0
  blue_cystals_red.region = 3 + int(type == Global.Layer.BLUE)
  blue_cystals_green.visible = crystals[0] & Global.LAYER_MASK[2] != 0
  blue_cystals_green.region = 5 + int(type == Global.Layer.BLUE)

  red_cystals_blue.visible = crystals[1] & Global.LAYER_MASK[0] != 0
  red_cystals_blue.region = 9 + int(type == Global.Layer.RED)
  red_cystals_green.visible = crystals[1] & Global.LAYER_MASK[2] != 0
  red_cystals_green.region = 7 + int(type == Global.Layer.RED)

  green_cystals_blue.visible = crystals[2] & Global.LAYER_MASK[0] != 0
  green_cystals_blue.region = 11 + int(type == Global.Layer.GREEN)
  green_cystals_red.visible = crystals[2] & Global.LAYER_MASK[1] != 0
  green_cystals_red.region = 13 + int(type == Global.Layer.GREEN)
