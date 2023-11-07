# For bosses
extends State

@onready var boss_node: BossEnemy = owner as BossEnemy


func enter(_msg := {}):
	# print('Boss state: Idle')
	get_parent().get_node('Attack/StateMachine').set_process(false)
	get_parent().get_node('Attack/StateMachine').set_physics_process(false)

func update(_delta: float) -> void:
	boss_node.move_direction = Vector2.ZERO
	# if seen, not lost -> attack
	if boss_node.has_seen_player and not boss_node.lost_player:
		state_machine.transition_to('Chase')
