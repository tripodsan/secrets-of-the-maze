class_name Level
extends Node2D

@onready var blue: ChromaLayer = $blue
@onready var red: ChromaLayer = $red
@onready var green: ChromaLayer = $green

@export var nr:int = -1

enum State {
  LOADED,
  READY,
  STARTING,
  STARTED,
  STOPPED,
  FINISHED,
  DESTROYED
}

var state:State = State.LOADED

signal state_changed()

signal chrystals_changed()

var _layers:Array[ChromaLayer] = [];

var _layer:ChromaLayer = null

var _prev_layer:ChromaLayer = null

var _game_data:GDLevel

var _start_portal:Portal
var _start_layer:ChromaLayer

var _level_run_time:int

class PickedUpCrystal extends RefCounted:
  var source:Global.Layer
  var type:Global.Layer
  func _init(s:Global.Layer, t:Global.Layer):
    source = s
    type = t

var _picked_up_crystals:Array[PickedUpCrystal] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  if nr < 0:
    prints('leftover scene level. discarding...')
    self.queue_free()
    return
  _layers = [blue, red, green]
  _game_data = GameData.get_level(nr)
  for l in _layers:
    var gd_layer:GDLayer = _game_data.get_layers()[l.type]
    l.set_game_data(gd_layer)
    l.set_active(false)
    l.visible = false
  Global.layer_selected.connect(_on_layer_selected)
  GameController.get_player_deferred(_on_player_loaded)
  GameController.portal_reached.connect(_on_portal_reached)
  GameController.set_level(self)
  set_state(State.READY)

func set_state(s:State)->void:
  state = s
  prints('layer state:', State.keys()[state])
  state_changed.emit()

func _on_player_loaded(p:Player)->void:
  p.state_changed.connect(_on_player_state_changed.bind(p))

func _on_player_state_changed(p:Player)->void:
  if p.state == Player.State.ACTIVE:
    _level_run_time = 0
  elif p.state == Player.State.DESTROYING:
    set_state(State.STOPPED)
  elif p.state == Player.State.DESTROYED:
    restart()
  elif p.state == Player.State.DEACTIVATING:
    # portal animation
    pass
  elif p.state == Player.State.DEACTIVATED:
    # portal animation finished
    set_state(State.FINISHED)

func _on_layer_selected(layer:ChromaLayer):
  if layer != _layer:
    if _layer:
      _layer.set_active(false)
    _prev_layer = _layer
    _layer = layer
    _layer.set_active(true)
    # show the layers where we have a crystal for
    for l in _layers:
      l.visible = _layer.game_data.has_crystal(l.type)
    for crystal:PickedUpCrystal in _picked_up_crystals:
      if crystal.source == _layer.type:
        _layers[crystal.type].visible = true

    _layer.visible = true

func _on_portal_reached(_p:Portal)->void:
  print('portal reached')
  # apply crystals
  for crystal:PickedUpCrystal in _picked_up_crystals:
    _layers[crystal.source].game_data.set_crystal(crystal.type)
    _layers[crystal.type].game_data.unlocked = true
  set_state(State.STOPPED)

func enable_layer(type:Global.Layer)->void:
  var layer:ChromaLayer = _layers[type]
  layer.visible = true

func force_chroma_shift(type:Global.Layer)->void:
  var layer:ChromaLayer = _layers[type]
  layer.visible = true
  Global.layer_selected.emit(layer)
  if !layer.can_chroma_shift(GameController.player.global_position):
    # move player to start portal
    GameController.player.global_transform = layer.get_portal(0).global_transform


func chroma_shift()->void:
  var pos = GameController.player.global_position
  var candidate:ChromaLayer = null
  for l in _layers:
    if l != _layer && l.can_chroma_shift(pos):
      if candidate == null:
        candidate = l
      elif candidate == _prev_layer:
        candidate = l
  if candidate:
    Global.layer_selected.emit(candidate)

func _process(_delta: float) -> void:
  if state == State.STARTED && _level_run_time >= 0:
    _level_run_time += int(_delta * 1000.0)
  if Input.is_action_just_pressed('switch'):
    chroma_shift()

func set_game_data(level:GDLevel)->void:
  _game_data = level

func start(layer:Global.Layer, portal:int = 0)->void:
  _layer = null
  _start_layer = _layers[layer]
  _start_portal = _start_layer.get_portal(portal)
  # disable start portals
  # todo: move to layer.reset()
  for l in _layers:
    l.get_portal(portal).enabled = false
  restart()
  get_viewport().get_camera_2d().reset_smoothing()

func quit()->void:
  set_state(State.DESTROYED)

func restart()->void:
  GameController.player.activate(_start_portal.global_transform)
  _picked_up_crystals.clear()
  chrystals_changed.emit()
  _on_layer_selected(_start_layer)
  # wait a frame to avoid immediate collisions
  #await get_tree().physics_frame
  #await get_tree().physics_frame
  for n:Node2D in get_tree().get_nodes_in_group('resetable'):
    n.reset()
  #Global.level_started.emit(self)
  set_state(State.STARTED)
  _level_run_time = -1 # timer still stopped

## returns the level time in milliseconds
func get_run_time()->int:
  return _level_run_time if _level_run_time >= 0 else 0;

func get_grid(layer:Global.Layer)->TileMapLayer:
  return _layers[layer].grid

func picked_up_crystal(layer_type:Global.Layer, crystal:Global.Layer)->void:
  prints('pikced up crystal %d in %d' % [crystal, layer_type])
  enable_layer(crystal)
  SoundController.play_sfx('crystal')
  _picked_up_crystals.append(PickedUpCrystal.new(layer_type, crystal))
  chrystals_changed.emit()

func add_blast(blast:Blast)->void:
  var pos = blast.global_position
  _layer.objects.add_child(blast)
  blast.global_position = pos
