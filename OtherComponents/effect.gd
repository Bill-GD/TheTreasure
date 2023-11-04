extends AnimatedSprite2D

func _ready():
	play()

func _on_animation_looped():
	queue_free()
