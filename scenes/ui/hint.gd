extends Control

@onready var lab_hint: RichTextLabel = %lab_hint
@onready var btn_resume: Button = %btn_resume

var original_text:String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  visible = false
  original_text = lab_hint.text
  GameController.show_crystal_hint.connect(show_crystal_hint)

var color_names = [
  '[color=#096aec]blue[/color]',
  '[color=#a23000]red[/color]',
  '[color=#386900]green[/color]'
]

func show_crystal_hint(layer:Global.Layer, crystal:Global.Layer)->void:
  lab_hint.text = original_text.replace('__layer__', color_names[layer]).replace('__crystal__', color_names[crystal])
  btn_resume.grab_focus()
  visible = true
  await fade(0.0, 1.0)

func close():
  await fade(1.0, 0.0)
  visible = false

func _on_btn_resume_pressed() -> void:
  close()
  GameController.resume_game()

func  fade(from:float, to:float)->void:
  modulate.a = from
  var tween:Tween = create_tween()
  tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
  tween.tween_property(self, 'modulate:a', to, 0.5)
  await tween.finished
