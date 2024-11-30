## TODO: convert to plugin
@tool
class_name LevelImporter
extends Node

@export var clear_level:bool = false:set = clear
@export var import_level:bool = false:set = import

@export var remove_fake_walls:bool = true
@export var import_red:bool = true
@export var import_blue:bool = true
@export var import_green:bool = true



@export var template:Texture2D
@export var template_scale:float = 16

## calculated automatically
@export var template_region:Rect2i

func _ready()->void:
  if !Engine.is_editor_hint():
    queue_free()

func _clear_layer(l:ChromaLayer):
  prints('clearing', l.name)
  for m in l.get_children():
    if m is TileMapLayer:
      m.clear()

func clear(_v):
  if !await prompt('Clear Level?'): return
  for l in get_parent().get_children():
    if l is ChromaLayer:
      _clear_layer(l)

func get_bb()->Rect2i:
  var size:Vector2 = template.get_size()
  var x0:int = Global.INT64_MAX
  var x1:int = 0
  var y0:int = Global.INT64_MAX
  var y1:int = 0
  var img:Image = template.get_image()
  for y:int in range(size.y):
    for x:int in range(size.x):
      var c:Color = img.get_pixel(x, y)
      if c != Color.BLACK:
        x0 = min(x0, x)
        x1 = max(x1, x)
        y0 = min(y0, y)
        y1 = max(y1, y)
  return Rect2i(x0, y0, x1-x0 + 1, y1-y0 + 1)

func _import_layer(l:ChromaLayer):
  var flags = [import_blue, import_red, import_green]
  var map_terrains := [2, 3, 1]
  var map_colors := [2, 0, 1]
  var idx = Global.Layer.get(l.name.to_upper())
  var cidx = map_colors[idx]
  if !flags[idx]: return
  prints('importing', l.name)
  var img:Image = template.get_image()
  @warning_ignore('integer_division')
  var wx = ceil(template_region.size.x / template_scale)
  @warning_ignore('integer_division')
  var wy = ceil(template_region.size.y / template_scale)
  var grid:TileMapLayer = l.get_node('grid')
  var map:TileMapLayer = l.get_node('map')
  var grid_cells:Array[Vector2i] = []
  var border_cells:Array[Vector2i] = []
  var wall_cells:Array[Vector2i] = []
  var DIRS:Array[Vector2i] = [
    Vector2i(-1, -1),
    Vector2i( 0, -1),
    Vector2i( 1, -1),
    Vector2i( 1,  0),
    Vector2i( 1,  1),
    Vector2i( 0,  1),
    Vector2i(-1,  1),
    Vector2i(-1,  0),
  ]
  for gy in range(wy):
    for gx in range(wx):
      var p = Vector2(gx*template_scale + template_region.position.x, gy*template_scale + template_region.position.y)
      var g = Vector2i(gx, gy)
      var c = img.get_pixelv(p)
      if c[cidx] > 0.2:
        grid_cells.append(g)
        var is_wall = false
        for n in DIRS:
          var nc = img.get_pixelv(Vector2(n)*template_scale + p)
          if nc[cidx] < 0.2:
            border_cells.append(g + n)
            is_wall = true
        if is_wall:
          wall_cells.append(g)

  grid.set_cells_terrain_connect(grid_cells, 0, idx)
  map.set_cells_terrain_connect(grid_cells, map_terrains[idx], 0, false)
  map.set_cells_terrain_connect(border_cells, map_terrains[idx], 2, false)
  if remove_fake_walls:
    for c in wall_cells:
      grid_cells.erase(c)
    for c in grid_cells:
      map.erase_cell(c)


func import(_v):
  if !await prompt('Import Level?'): return
  template_region = get_bb()
  prints('level size:', template_region.size / template_scale)
  for l in get_parent().get_children():
    if l is ChromaLayer:
      _import_layer(l)

func prompt(title:String)->bool:
  # create popup
  var popup := Window.new()
  popup.hide()
  popup.mode = Window.MODE_WINDOWED
  popup.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
  popup.extend_to_title = true
  popup.size = Vector2i(400, 200)
  popup.title = title
  popup.keep_title_visible = true
  popup.exclusive = true
  popup.force_native = true
  popup.unfocusable = false
  popup.wrap_controls = true

  var container := VBoxContainer.new()
  popup.add_child(container)

  var label := Label.new()
  label.text = "\n\n%s\n\nAre you sure\n\n" % title
  label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
  label.set_anchors_preset(Control.PRESET_FULL_RECT)
  container.add_child(label)

  var ret := [false]

  var btn_ok := Button.new()
  btn_ok.text = "ok"
  btn_ok.pressed.connect(func (): ret[0] = true; popup.queue_free())
  container.add_child(btn_ok)

  var btn_no := Button.new()
  btn_no.text = "cancel"
  btn_no.pressed.connect(func (): popup.queue_free())
  container.add_child(btn_no)

  EditorInterface.popup_dialog_centered(popup)

  await popup.tree_exited
  return ret[0]
