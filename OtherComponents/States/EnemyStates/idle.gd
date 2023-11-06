# For normal enemies
extends State

@onready var enemy_node: Enemy = owner as Enemy


func update(_delta: float) -> void:
	enemy_node.move_direction = Vector2.ZERO
	# if seen, not lost -> attack
	if enemy_node.has_seen_player and not enemy_node.lost_player:
		state_machine.transition_to('Attack')
