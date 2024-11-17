class_name LevelSuffixLabel
extends Label

var COLORS:Array[Color] = [
  Color('#096aec'),
  Color('#a23000'),
  Color('#386900')
]

var SUFFIXES:Array[String] = [
  '-B',
  '-R',
  '-G'
]

var color_scheme:Global.Layer = Global.Layer.BLUE: set = set_color_scheme

func set_color_scheme(v:Global.Layer)->void:
  color_scheme = v
  if label_settings:
    label_settings.font_color = COLORS[v]
  else:
    add_theme_color_override('font_color', COLORS[v])
  text = SUFFIXES[v]
