# For bosses
extends State

@onready var boss_node: BossEnemy = owner as BossEnemy
@onready var attack_timer: Timer = $AttackTimer
@onready var weapon_node: Sprite2D
@onready var shotgun_tex: Texture2D = preload('res://Assets/Sprites/shotgun.png')

var is_aiming: bool = false
var has_attacked: bool = false
var circling_direction: int


func enter(_msg := {}):
	# print('Boss chosen attack: Spread Shot')
	weapon_node = boss_node.sprite.get_node('Weapon')
	weapon_node.set_texture(shotgun_tex)
	has_attacked = false
	is_aiming = true
	attack_timer.start()
	boss_node.speed = boss_node.BASE_SPEED / (3 - boss_node.level * 0.2)

func update(_delta: float) -> void:
	if has_attacked:
		state_machine.transition_to('ChooseAttack')
		return
	else:
		var target_direction: Vector2 = boss_node.target.global_position - boss_node.global_position
		if is_aiming:
			boss_node.move_direction = target_direction.orthogonal() * circling_direction
			boss_node.sprite.rotation = target_direction.angle()
		else:
			var shoot_direction: Vector2 = target_direction.normalized()
			var shoot_position: Vector2 = weapon_node.global_position + Vector2.RIGHT.rotated(boss_node.sprite.rotation) * weapon_node.get_rect().size.x / 2
			boss_node.get_node('ShootSound').play()
			boss_node.get_node('SingleBulletAttack').shoot_bullet(boss_node, shoot_direction, shoot_position)
			boss_node.get_node('SingleBulletAttack').shoot_bullet(boss_node, Vector2.RIGHT.rotated(shoot_direction.angle() + -PI/12).normalized(), shoot_position)
			boss_node.get_node('SingleBulletAttack').shoot_bullet(boss_node, Vector2.RIGHT.rotated(shoot_direction.angle() + PI/12).normalized(), shoot_position)
			has_attacked = true

func exit() -> void:
	has_attacked = false

func _on_attack_timer_timeout():
	is_aiming = false
