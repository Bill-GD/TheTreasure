extends Area2D

@onready var player: Player = get_parent()
@onready var health_bar: HealthBar = get_parent().get_node('HealthBar')
@onready var armor_bar: ProgressBar = get_parent().get_node('ArmorBar')

func _on_body_entered(body:Node2D):
	if body is Bullet and (body.shooter is BossEnemy or body.shooter is Enemy):
		body.hit.emit()
		if player.current_armor > 0:
			player.current_armor -= body.actual_damage
			armor_bar.update_armor(player.current_armor, player.BASE_ARMOR)
		else: player.current_hp -= body.actual_damage

		if player.current_hp <= 0:
			player.died.emit()
			
		player.armor_regen_timer.stop()
		player.armor_regen_delay_timer.start()

		health_bar.update_health(player.current_hp, player.BASE_HP)
		# body.queue_free()
