# For normal enemies
extends State

@onready var enemy_node: Enemy = owner as Enemy


func update(_delta: float) -> void:
	# If seen, lost -> pathfind
	if enemy_node.has_seen_player and enemy_node.lost_player:
		state_machine.transition_to('Search')
		return
		
	if enemy_node.target:
		var close_range_distance: float = enemy_node.get_node('PlayerDetection/CloseRange/CloseRangeShape').shape.radius
		var target_direction: Vector2 = enemy_node.target.global_position - enemy_node.global_position
		var distance_to_target: float = target_direction.length()
		
		enemy_node.sprite.rotation = target_direction.angle()
		# if seen, not lost and is close -> circle, not close -> chase
		if enemy_node.player_close_range:
			enemy_node.move_direction = target_direction.orthogonal()
			if distance_to_target < close_range_distance:
				enemy_node.move_direction += target_direction.normalized() * -(close_range_distance - distance_to_target)
		else:
			enemy_node.move_direction = target_direction

		if enemy_node.attack_cooldown_timer.is_stopped():
			enemy_node.get_node('ShootSound').play()
			enemy_node.get_node('SingleBulletAttack').shoot_bullet(enemy_node, enemy_node.target.global_position - enemy_node.global_position)
			enemy_node.attack_cooldown_timer.start()
