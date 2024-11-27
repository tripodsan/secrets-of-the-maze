class_name MultPathFollow
extends Path2D

@export var speed:float = 250.0

@export var _layer_parents:Array[Node2D]

var _targets:Array[Node2D] = []

var _portals:Array[MinePortal] = []

var _start_type:Global.Layer

var offset:float = 0

func _ready() -> void:
  for n in get_children():
    if n is MinePortal:
      n.curve_offset = curve.get_closest_offset(n.global_position)
      _portals.append(n)
      remove_child(n)
    else:
      _targets.append(n)
  _portals.sort_custom(func (a,b): return a.curve_offset < b.curve_offset)
  _start_type = _portals[-1].type
  distribute_targets()

func distribute_targets()->void:
  var l = len(_targets)
  for i in range(l):
    var ofs = fmod(remap(i, 0, l, 0, curve.get_baked_length()) + offset, curve.get_baked_length())
    var pos:Vector2 = curve.sample_baked(ofs, true)
    var type = _start_type
    for m:MinePortal in _portals:
      if ofs < m.curve_offset:
        break
      type = m.type
    var mine = _targets[i]
    mine.reparent(_layer_parents[type])
    mine.global_position = to_global(pos)

func _process(delta:float)->void:
  offset = fmod(offset + delta * speed, curve.get_baked_length())
  distribute_targets()
