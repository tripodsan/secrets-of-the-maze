## TODO: convert to plugin
@tool
class_name LevelImporter
extends Node

@export var clear_level:bool = false:set = clear;

func _clear_layer(l:ChromaLayer):
  prints('clearing', l.name)

func _do_clear():
  for l in get_parent().get_children():
    if l is ChromaLayer:
      _clear_layer(l)

func clear(v):
  # create popup
  var popup := Window.new()
  popup.hide()
  popup.mode = Window.MODE_WINDOWED
  popup.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
  popup.extend_to_title = true
  popup.size = Vector2i(400, 200)
  popup.title = "Clear Level"
  popup.keep_title_visible = true
  popup.exclusive = true
  popup.force_native = true
  popup.unfocusable = false
  popup.wrap_controls = true

  var container := VBoxContainer.new()
  popup.add_child(container)

  var label := Label.new()
  label.text = "\n\nClear Level.\n\nAre you sure\n\n"
  label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
  label.set_anchors_preset(Control.PRESET_FULL_RECT)
  container.add_child(label)

  var btn_ok := Button.new()
  btn_ok.text = "ok"
  btn_ok.pressed.connect(func (): popup.queue_free(); _do_clear())
  container.add_child(btn_ok)

  var btn_no := Button.new()
  btn_no.text = "cancel"
  btn_no.pressed.connect(func (): popup.queue_free())
  container.add_child(btn_no)

  EditorInterface.popup_dialog_centered(popup)
