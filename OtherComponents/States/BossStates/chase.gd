# For bosses
extends State

@onready var boss_node: BossEnemy = owner as BossEnemy


func enter(_msg := {}):
	# print('Boss state: Chase')
	get_parent().get_node('Attack/StateMachine').set_process(false)
	get_parent().get_node('Attack/StateMachine').set_physics_process(false)

func update(_delta: float) -> void:
	if boss_node.target:
		boss_node.move_direction = boss_node.target.global_position - boss_node.global_position
		boss_node.sprite.rotation = boss_node.move_direction.angle()

	# If seen, lost -> pathfind
	if boss_node.has_seen_player:
		if boss_node.lost_player:
			state_machine.transition_to('Search')
			return
		if boss_node.player_close_range and not boss_node.lost_player:
			state_machine.transition_to('Attack')
			return
