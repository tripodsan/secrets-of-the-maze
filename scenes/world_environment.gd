extends WorldEnvironment

func _ready() -> void:
  RenderingServer.set_default_clear_color(Color.BLACK)
  if RenderingServer.get_rendering_device() == null:
    # compat mode
    prints('Compatibility mode.')
    environment = load('res://scenes/compat_env.tres')
  else:
    prints('Forward+')
