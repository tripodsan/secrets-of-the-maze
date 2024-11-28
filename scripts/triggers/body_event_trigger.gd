@tool
extends Trigger
class_name BodyEventTrigger

var _source:Node2D

func _enter_tree():
  _validate()

func _ready():
  _validate()
  if _source:
    _source.body_entered.connect(_on_body_entered)
    _source.body_exited.connect(_on_body_exited)

func _notification(what):
  if what == NOTIFICATION_CHILD_ORDER_CHANGED:
    _validate()

func _validate()->void:
  _source = get_parent()
  if !_source.has_signal('body_entered') || !_source.has_signal('body_exited'):
    _source = null
  update_configuration_warnings()

func _get_configuration_warnings():
  if !_source:
    return ['Missing parent with body_entered events']

func _on_body_entered(n: Node2D):
  if n is Player:
    activate.emit()

func _on_body_exited(n: Node2D):
  if n is Player:
    deactivate.emit()
