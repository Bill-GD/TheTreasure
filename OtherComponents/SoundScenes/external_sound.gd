# For sounds that plays right before parent is freed (queue_free)
extends AudioStreamPlayer2D

func _ready():
	play()

func _on_finished():
	queue_free()
