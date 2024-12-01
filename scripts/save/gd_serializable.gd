## base class for game data settingd that can be saved and loaded
## note: it extends `Node`,so that it can be inspected easier in the editor
class_name GDSerializable
extends Node

## returns a dictionary with all the exported properties recursively
## note: that if an exported property has the same name as a child node,
##       the property is not exported (i.e. it is overwritten by the node)
func to_dict()->Dictionary:
  var ret := {}
  for p:Dictionary in get_property_list():
    if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE && !p.name.begins_with('_'):
      var value = self.get(p.name)
      if value is GDSerializable:
        value = value.to_dict()
      ret[p.name] = value

  for n in get_children():
    if n is GDSerializable:
      if ret.has(n.name):
        printerr('warning: serialization of child node %s shadows exported property' % n.get_path())
      ret[n.name] = n.to_dict()
  return ret

func reset()->void:
  for n in get_children():
    if n is GDSerializable:
      n.reset()

func from_dict(dict:Dictionary)->void:
  for p:Dictionary in get_property_list():
    if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE && !p.name.begins_with('_'):
      var data = dict.get(p.name)
      if data != null:
        var value = self.get(p.name)
        if value is GDSerializable:
          #prints('descending...', get_path(), p.name)
          value.from_dict(data)
        else:
          #prints('setting', get_path(), p.name, data)
          self.set(p.name, data)

  for n in get_children():
    if n is GDSerializable:
      var data = dict.get(n.name)
      if data is Dictionary:
        n.from_dict(data)
