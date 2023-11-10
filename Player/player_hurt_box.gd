extends Area2D

@onready var player: Player = get_parent()


func _on_body_entered(body: Node2D):
	if body is Bullet and (body.shooter == null or not body.shooter is Player):
		$SoundEffect.play()
		body.hit_entity.emit()
		if player.current_armor > 0:
			player.current_armor -= min(body.actual_damage, player.current_armor)
			player.update_armor_displays()
		else: player.current_hp -= body.actual_damage

		if player.current_hp <= 0:
			player.died.emit()
			
		player.armor_regen_timer.stop()
		player.armor_regen_delay_timer.start()

		player.update_health_displays()

func _on_mouse_entered():
	print('Player: HP = %s, Armor = %s' % [player.current_hp, player.current_armor])
