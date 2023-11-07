# For bosses
extends State

@onready var boss_node: BossEnemy = owner as BossEnemy
@onready var attack_cooldown_timer: Timer = $AttackCooldown
@onready var attack_state: State = get_parent().get_parent()


func enter(_msg := {}):
	# print('Boss state: Choosing attack')
	attack_state.is_attacking = false
	attack_cooldown_timer.start()

func update(_delta: float) -> void:
	boss_node.move_direction = Vector2.ZERO

func _on_attack_cooldown_timeout():
	if boss_node.available_attacks.size() > 0:
		attack_state.is_attacking = true
		var chosen_attack = boss_node.ATTACKS[boss_node.available_attacks[randi() % len(boss_node.available_attacks)]]

		match chosen_attack:
			boss_node.ATTACKS.SHOOT_NORMAL:
				attack_cooldown_timer.wait_time = 1
				state_machine.transition_to('SingleShot')
			boss_node.ATTACKS.SHOOT_SPREAD:
				attack_cooldown_timer.wait_time = 1
				state_machine.transition_to('SpreadShot')
			boss_node.ATTACKS.SPIN:
				attack_cooldown_timer.wait_time = 2 + boss_node.level * 0.2
				state_machine.transition_to('Spin')
