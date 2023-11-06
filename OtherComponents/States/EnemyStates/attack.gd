# For normal enemies
extends State

@onready var enemy_node: Enemy = owner as Enemy


func update(_delta: float) -> void:
	# If seen, lost -> pathfind
	if enemy_node.has_seen_player and enemy_node.lost_player:
		state_machine.transition_to('Search')
		return

	# if seen, not lost and is close -> circle, not close -> chase
	if enemy_node.player_close_range:
		enemy_node.move_direction = (enemy_node.target.global_position - enemy_node.global_position).orthogonal()
	else:
		enemy_node.move_direction = enemy_node.target.global_position - enemy_node.global_position

	if enemy_node.attack_cooldown_timer.is_stopped():
		enemy_node.get_node('ShootSound').play()
		enemy_node.get_node('SingleBulletAttack').shoot_bullet(enemy_node, enemy_node.target.global_position - enemy_node.global_position)
		enemy_node.attack_cooldown_timer.start()
