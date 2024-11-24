class_name LevelTimer
extends HBoxContainer

@onready var level_time_secs: Label = $level_time_secs
@onready var level_time_ts: Label = $level_time_ts

var prev_time:int = -1

func set_time(msec:int)->void:
  var t:int = msec / 10
  if t != prev_time:
    prev_time = t
    var s = t / 100
    level_time_secs.text = '%d:%02d' % [s / 60, s % 60]
    level_time_ts.text = '.%d' % [t % 100]
