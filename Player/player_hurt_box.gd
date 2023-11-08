extends Area2D

@onready var player: Player = get_parent()
@onready var health_bar: HealthBar = get_parent().get_node('HealthBar')
@onready var armor_bar: ProgressBar = get_parent().get_node('ArmorBar')


func _on_body_entered(body: Node2D):
	if body is Bullet and (body.shooter == null or not body.shooter is Player):
		$SoundEffect.play()
		body.hit_entity.emit()
		if player.current_armor > 0:
			player.current_armor -= min(body.actual_damage, player.current_armor)
			armor_bar.update_armor(player.current_armor, player.total_armor)
		else: player.current_hp -= body.actual_damage

		if player.current_hp <= 0:
			player.died.emit()
			
		player.armor_regen_timer.stop()
		player.armor_regen_delay_timer.start()

		health_bar.update_health(player.current_hp, player.total_hp)

func _on_mouse_entered():
	print('Player: HP = %s, Armor = %s' % [player.current_hp, player.current_armor])
