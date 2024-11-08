extends Node2D


func fire() -> void:
  $Sparks.emitting = true
  $Fireballs.emitting = true
  $Smoke.emitting = true
  $InitialFlash.emitting = true
