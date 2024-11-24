## The GameData acts as meta contains for level information as well as for
## loading and saving progress and settings.
## the variables that exported and do not start with `_` are saved.
## note that only unlocked levels are saved, in order to keep
## the undiscovered levels a "secret" :-)
extends Node

func load_file(_file_name:String)->void:
  pass

func save_file(file_name:String)->void:
  var root:GDSerializable = get_node('save')
  assert(root)
  var file = FileAccess.open("user://saves_%s.json" % file_name, FileAccess.WRITE)
  var error = FileAccess.get_open_error()
  if error != OK:
    printerr('failed to open save_file: ', error_string(error))
    return
  var data = root.to_dict()
  var json_string = JSON.stringify(data, '  ')
  file.store_line(json_string)
  prints('save game data to:', file.get_path_absolute())

func reset()->void:
  get_levels().reset()
  get_level(0).unlock()

func get_levels()->GDSerializable:
  return $save/levels

func get_level(nr:int)->GDLevel:
  return get_node_or_null('save/levels/%d' % nr)

func unlock_next_level(lvl:GDLevel)->void:
  var next = get_level(lvl.get_nr() + 1)
  if next:
    next.unlock()

func get_layer(nr:int, layer:Global.Layer)->GDLayer:
  if layer < 0 || layer > Global.Layer.GREEN: return
  var lvl:GDLevel = get_level(nr)
  if !lvl: return
  return lvl.get_layers()[layer]
