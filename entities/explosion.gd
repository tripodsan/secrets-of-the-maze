class_name Explosion
extends Node2D

func explode()->void:
  $Flash.emitting = true
  $Particles.emitting = true
