class_name DamageText
extends Label

var velocity: Vector2 = 30 * Vector2.UP

func _ready():
	$DisplayTimer.start()
	
func _process(delta):
	position += delta * velocity

func _on_display_timer_timeout():
	queue_free()
