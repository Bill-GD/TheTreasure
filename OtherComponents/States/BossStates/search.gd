# For bosses
extends State

@onready var boss_node: BossEnemy = owner as BossEnemy


func enter(_msg := {}):
	print('Boss state: Search')
	boss_node.nav_agent.update_target_position(boss_node.target.global_position)
	if not boss_node.nav_agent.is_connected('navigation_finished', _on_navigation_finished): boss_node.nav_agent.connect('navigation_finished', _on_navigation_finished)

func update(_delta: float) -> void:
	boss_node.move_direction = boss_node.nav_agent.get_next_path_position() - boss_node.position

	# if in sight, close -> attack, far -> chase
	if boss_node.has_seen_player and boss_node.player_in_detect_range and not boss_node.lost_player:
		if boss_node.player_close_range:
			state_machine.transition_to('Attack')
		else:
			state_machine.transition_to('Chase')

func _on_navigation_finished():
	state_machine.transition_to('Idle')