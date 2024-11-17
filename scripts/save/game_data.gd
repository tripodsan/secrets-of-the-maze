extends Node

func load_file(name:String)->void:
  pass

func save_file(name:String)->void:
  var root:GDSerializable = get_node('save')
  assert(root)
  var save_file = FileAccess.open("user://saves_%s.json" % name, FileAccess.WRITE)
  var error = FileAccess.get_open_error()
  if error != OK:
    printerr('failed to open save_file: ', error_string(error))
    return
  var data = root.to_dict()
  var json_string = JSON.stringify(data, '  ')
  save_file.store_line(json_string)
  prints('save game data to:', save_file.get_path_absolute())
  pass

func reset()->void:
  pass

func get_levels()->GDSerializable:
  return $save/levels
