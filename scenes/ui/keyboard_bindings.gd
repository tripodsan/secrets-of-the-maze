class_name KeyboardBindings
extends MarginContainer

@onready var inputs: GridContainer = $controls/keyboard_bindings/inputs

signal closed()

class Selection:
  var action:String
  var label:Label
  var button:Button
  var idx:int
  func _init(a:String, i:int, l:Label, b:Button):
    idx = i
    action = a
    label = l
    button = b

static var action_map:Dictionary = {}

var _selection:Selection = null

const ignored_actions:Array[String] = ['debug', 'console']

static var config_path:String = 'user://settings.cfg'

static var config:ConfigFile = ConfigFile.new()

var first_btn:Button

func _ready() -> void:
  load_settings()
  if !action_map:
    update_action_map()
  do_create()

func focus()->void:
  first_btn.grab_focus()

func update_action_map():
  action_map.clear()
  for action in InputMap.get_actions():
    if !action.begins_with('ui_') and !ignored_actions.has(action):
      var events:Array[InputEventKey] = []
      for event in InputMap.action_get_events(action):
        if event is InputEventKey:
          events.append(event)
      while events.size() < 2:
        events.append(null)
      action_map[action] = events

static func update_action(action:String)->void:
  var events = InputMap.action_get_events(action)
  InputMap.action_erase_events(action)
  # add non key events
  for evt in events:
    if not evt is InputEventKey:
      InputMap.action_add_event(action, evt)
  for evt in action_map[action]:
    if evt:
      InputMap.action_add_event(action, evt)

func save_settings():
  config.set_value('input', 'keybinds', action_map)
  var error = config.save(config_path)
  if error:
    print('error saving settings: ', error)
  else:
    print('settings saved to ', ProjectSettings.globalize_path(config_path))

static func load_settings():
  var error = config.load(config_path)
  if error:
    print('unable to load config: ', error)
    return
  action_map = config.get_value('input', 'keybinds')
  for action in action_map:
    update_action(action)

func reset():
  InputMap.load_from_project_settings()
  update_action_map()
  save_settings()

func close():
  closed.emit()

func _input(event:InputEvent):
  if not event is InputEventKey: return
  if _selection:
    if event.keycode & KEY_MODIFIER_MASK > 0:
      if event.is_pressed():
        # ignore modifier if pressed first
        return
    action_map[_selection.action][_selection.idx] = event
    update_action(_selection.action)
    save_settings()
    _selection.button.text = event.as_text_physical_keycode()
    _selection = null
    inputs.focus_mode = Control.FOCUS_ALL
    inputs.process_mode = Node.PROCESS_MODE_INHERIT
    get_viewport().set_input_as_handled()
  elif event.pressed and event.keycode == KEY_ESCAPE and visible:
    close()

func do_create()->void:
  var t_action:Label
  var t_keyboard:Button
  first_btn = null
  for c in inputs.get_children():
    if c.name == 'template_action':
      t_action = c
      c.visible = false
    elif c.name == 'template_keyboard':
      t_keyboard = c
      c.visible = false
    elif not c.name.begins_with('hdr_') and not c.name.begins_with('ign_'):
      c.queue_free()
  for action in InputMap.get_actions():
    if not action_map.has(action): continue
    var action_label:Label = null
    var idx = 0
    for event:InputEventKey in action_map[action]:
      if action_label == null:
        action_label = t_action.duplicate()
        action_label.text = tr(action)
        action_label.visible = true
        inputs.add_child(action_label)
        if Engine.is_editor_hint():
          action_label.owner = owner
      var k:Button = t_keyboard.duplicate()
      if !first_btn: first_btn = k
      k.text = event.as_text_physical_keycode() if event else '-'
      k.visible = true
      k.pressed.connect(_on_keyboard_btn.bind(Selection.new(action, idx, action_label, k)))
      inputs.add_child(k)
      idx += 1

func _on_keyboard_btn(selection:Selection)->void:
  selection.button.text = '[press key]'
  _selection = selection
  inputs.process_mode = Node.PROCESS_MODE_DISABLED
  inputs.focus_mode = Control.FOCUS_NONE

func _on_btn_reset_pressed() -> void:
  reset()
  do_create()

func _on_btn_back_pressed() -> void:
  close()
