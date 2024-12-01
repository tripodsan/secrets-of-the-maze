## The GameData acts as meta contains for level information as well as for
## loading and saving progress and settings.
## the variables that exported and do not start with `_` are saved.
extends Node

const default_save = '0'

func load_file(file_name:String = default_save)->void:
  var file = FileAccess.open("user://saves_%s.json" % file_name, FileAccess.READ)
  var error = FileAccess.get_open_error()
  if error != OK:
    printerr('failed to open save_file: ', error_string(error))
    reset()
    return
  pass

func save_file(file_name:String = default_save)->void:
  var root:GDSerializable = get_node('save')
  assert(root)
  var file = FileAccess.open("user://saves_%s.json" % file_name, FileAccess.WRITE)
  var error = FileAccess.get_open_error()
  if error != OK:
    printerr('failed to open save_file: ', error_string(error))
    return
  get_progress().touch()
  var data = root.to_dict()
  var json_string = JSON.stringify(data, '  ')
  file.store_line(json_string)
  prints('save game data to:', file.get_path_absolute())

func reset()->void:
  get_levels().reset()
  get_progress().reset()
  get_level(0).unlock(0)

func unlock_all(crystals:bool)->void:
  for lvl:GDLevel in get_levels().get_children():
    lvl.unlock_all(crystals)

func get_levels()->GDSerializable:
  return $save/levels

func get_level(nr:int)->GDLevel:
  return get_node_or_null('save/levels/%d' % nr)

## unlocks the next level and respective layer
func unlock_next_level(lay:GDLayer):
  var next = get_level(lay.get_level().get_nr() + 1)
  if next:
    prints('unlocking level', next)
    next.unlock(lay.type)

func get_settings()->GDSettings:
  return $save/settings

func get_progress()->GDProgress:
  return $save/progress

func get_layer(nr:int, layer:Global.Layer)->GDLayer:
  if layer < 0 || layer > Global.Layer.GREEN: return
  var lvl:GDLevel = get_level(nr)
  if !lvl: return
  return lvl.get_layers()[layer]
