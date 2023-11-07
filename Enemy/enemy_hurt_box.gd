extends Area2D

@onready var parent: CharacterBody2D = get_parent()
@onready var player: Player = parent.target
@onready var health_bar: HealthBar = get_parent().get_node('HealthBar')

func _on_body_entered(body:Node2D):
	if body != null:
		if body is Bullet and (body.shooter == null or body.shooter is Player):
			$SoundEffect.play()
			body.hit_entity.emit()
			parent.current_hp -= body.actual_damage
			health_bar.update_health(parent.current_hp, parent.total_hp)

func _on_mouse_entered():
	print('%s: HP = %s' % ['Enemy' if parent is Enemy else 'Boss', parent.current_hp])