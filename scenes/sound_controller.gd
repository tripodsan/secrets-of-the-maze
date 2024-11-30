extends Node

@onready var bg_player: AudioStreamPlayer = $bg_player
@onready var sfx_player: AudioStreamPlayer = $sfx_player
@onready var intro_player: AudioStreamPlayer = $intro_player

@export var sfx_names:Array[StringName] = []
@export var sfx_streams:Array[AudioStream] = []


var sfx:Dictionary = {}
var sfx_looped:Dictionary = {}


var current_clip:String

func _ready() -> void:
  GameController.level_loaded.connect(_on_level_loaded)
  GameController.game_paused.connect(_on_game_paused)
  GameController.game_resumed.connect(_on_game_resumed)
  for i in len(sfx_names):
    sfx[sfx_names[i]] = sfx_streams[i]

func _on_level_loaded(level:Level)->void:
  level.state_changed.connect(_on_level_state_changed.bind(level))

func _on_level_state_changed(level:Level)->void:
  if level.state == Level.State.STARTED:
    if !bg_player.playing || current_clip == "title":
      bg_player.volume_db = 0
      bg_player.play()
      current_clip = "level_%d" % level.nr
      bg_player.get_stream_playback().switch_to_clip_by_name(current_clip)
  elif level.state == Level.State.FINISHED:
    play_title()
  elif level.state == Level.State.DESTROYED:
    play_title()

func play_title():
  if current_clip != 'title':
    current_clip = 'title'
    bg_player.play()
    bg_player.get_stream_playback().switch_to_clip_by_name(current_clip)


func play_sfx(name:StringName, toggle:bool = false, volume_db:float = 0.0)->void:
  sfx_player.play()
  if !sfx_player.playing:
    sfx_player.play()
  var pb:AudioStreamPlaybackPolyphonic = sfx_player.get_stream_playback()
  var idx:int = pb.play_stream(sfx[name], 0, volume_db)
  if idx == AudioStreamPlaybackPolyphonic.INVALID_ID:
    printerr('unable to play sfx: %s' % name)
  if toggle:
    sfx_looped[name] = idx

func stop_sfx(name:StringName)->void:
  if sfx_looped.has(name):
    var pb:AudioStreamPlaybackPolyphonic = sfx_player.get_stream_playback()
    pb.stop_stream(sfx_looped[name])
    sfx_looped.erase(name)

func _on_game_paused()->void:
  Global.change_volume(bg_player, -20)

func _on_game_resumed()->void:
  Global.change_volume(bg_player, 0)

func play_intro():
  intro_player.volume_db = -80
  intro_player.play()
  Global.change_volume(intro_player, 0, 1.0)

func stop_intro():
  Global.change_volume(intro_player, -80, 3.0, true)
