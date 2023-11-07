# For bosses
extends State

@onready var boss_node: BossEnemy = owner as BossEnemy
@onready var attack_timer: Timer = $AttackTimer
@onready var pistol_tex: Texture2D = preload('res://Assets/Sprites/pistol.png')

var is_aiming: bool = false
var has_attacked: bool = false


func enter(_msg := {}):
	# print('Boss chosen attack: Single Shot')
	boss_node.sprite.get_node('Weapon').set_texture(pistol_tex)
	has_attacked = false
	is_aiming = true
	attack_timer.start()

func update(_delta: float) -> void:
	if has_attacked:
		state_machine.transition_to('ChooseAttack')
		return
	else:
		var target_direction: Vector2 = boss_node.target.global_position - boss_node.global_position
		if is_aiming:
			boss_node.sprite.rotation = target_direction.angle()
		else:
			var shoot_direction: Vector2 = target_direction.normalized()
			boss_node.get_node('ShootSound').play()
			boss_node.get_node('SingleBulletAttack').shoot_bullet(boss_node, shoot_direction)
			has_attacked = true

func exit() -> void:
	has_attacked = false

func _on_attack_timer_timeout():
	is_aiming = false
