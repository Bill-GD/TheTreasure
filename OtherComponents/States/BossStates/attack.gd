# For bosses
extends State

@onready var boss_node: BossEnemy = owner as BossEnemy


func enter(_msg := {}):
	print('Boss state: Attack')

func update(_delta: float) -> void:
	boss_node.move_direction = Vector2.ZERO
	
	# If seen, lost -> pathfind
	if boss_node.has_seen_player and boss_node.lost_player:
		state_machine.transition_to('Search')
		return
	if not boss_node.player_close_range:
		state_machine.transition_to('Chase')
		return
