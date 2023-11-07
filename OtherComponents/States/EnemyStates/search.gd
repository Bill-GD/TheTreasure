# For normal enemies
extends State

@onready var enemy_node: Enemy = owner as Enemy


func enter(_msg := {}):
	if enemy_node.target:
		enemy_node.nav_agent.update_target_position(enemy_node.target.global_position)
	if not enemy_node.nav_agent.is_connected('navigation_finished', _on_navigation_finished): enemy_node.nav_agent.connect('navigation_finished', _on_navigation_finished)

func update(_delta: float) -> void:
	enemy_node.move_direction = enemy_node.nav_agent.get_next_path_position() - enemy_node.position
	enemy_node.sprite.rotation = enemy_node.move_direction.angle()

	if enemy_node.has_seen_player and enemy_node.player_in_detect_range and not enemy_node.lost_player:
		state_machine.transition_to('Attack')

func _on_navigation_finished():
	state_machine.transition_to('Idle')
