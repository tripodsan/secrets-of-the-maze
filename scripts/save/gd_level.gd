## GameData for Levels
class_name GDLevel
extends GDSerializable

var _ROMAN:Array[String] = ['O', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X']

@export var unlocked:bool = false

var _layers:Array[GDLayer] = []

func _ready() -> void:
  for n in $layers.get_children():
    _layers.append(n)

func get_layers()->Array[GDLayer]:
  return _layers

func get_nr()->int:
  return int(str(name))

func get_title()->String:
  return 'D%s' % _ROMAN[get_nr() + 1]

func reset()->void:
  unlocked = false
  super.reset()

func unlock_all(crystals:bool)->void:
  unlocked = true
  for lay:GDLayer in _layers:
    lay.unlocked = true
    if crystals:
      lay.crystals = 7
      lay.secrets = (2**lay.max_secrets) - 1

func unlock(type:int)->void:
  unlocked = true
  _layers[type].unlocked = true
