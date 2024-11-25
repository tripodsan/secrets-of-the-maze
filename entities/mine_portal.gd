## helper node to tell wandering mines where to switch layer
class_name MinePortal
extends Marker2D

@export var type:Global.Layer = Global.Layer.BLUE

## set externally by the mine_path
var curve_offset:float = 0.0
