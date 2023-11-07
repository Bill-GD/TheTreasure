# For bosses
extends State

@onready var boss_node: BossEnemy = owner as BossEnemy

var is_attacking: bool = false

enum ATTACKS {
	SHOOT_NORMAL,
	SHOOT_SPREAD,
	SPIN,
}


func enter(_msg := {}):
	# print('Boss state: Attack')
	$StateMachine.set_process(true)
	$StateMachine.set_physics_process(true)
	$StateMachine/ChooseAttack.attack_cooldown_timer.start()

func update(_delta: float) -> void:
	boss_node.move_direction = Vector2.ZERO
	
	# If seen, lost -> pathfind
	if not is_attacking:
		if boss_node.has_seen_player and boss_node.lost_player:
			state_machine.transition_to('Search')
			return
		if not boss_node.player_close_range:
			state_machine.transition_to('Chase')
			return
