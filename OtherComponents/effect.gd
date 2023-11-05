extends AnimatedSprite2D

func _ready():
	if has_node('SoundEffect'): $SoundEffect.play()
	play()

func _on_animation_looped():
	queue_free()
