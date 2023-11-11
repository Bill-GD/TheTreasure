# For bosses
extends State

@onready var boss_node: BossEnemy = owner as BossEnemy
@onready var weapon_node: Sprite2D
@onready var assault_tex: Texture2D = preload('res://Assets/Sprites/assault_rifle.png')

var tween: Tween
var is_spinning: bool = false
var has_attacked: bool = false
@onready var frames_between_shots: int = max(1, floor(6) / boss_node.level)
var current_frame: int = 0

func enter(_msg := {}) -> void:
	# print('Boss chosen attack: Spin')
	current_frame = randi_range(0, frames_between_shots - 1)
	weapon_node = boss_node.sprite.get_node('Weapon')
	weapon_node.set_texture(assault_tex)
	has_attacked = false
	boss_node.sprite.rotation = (boss_node.target.global_position - boss_node.global_position).angle()
	boss_node.speed = 0 + (boss_node.level - 1) * (boss_node.BASE_SPEED / 2)
	spin()

func update(_delta: float) -> void:
	if has_attacked:
		state_machine.transition_to('ChooseAttack')
		return
	else:
		if is_spinning:
			var target_direction: Vector2 = boss_node.target.global_position - boss_node.global_position
			boss_node.move_direction = target_direction
			if current_frame == 0:
				boss_node.get_node('ShootSound').play()
				boss_node.get_node('SingleBulletAttack').shoot_bullet(boss_node, Vector2.RIGHT.rotated(boss_node.sprite.rotation), weapon_node.global_position + Vector2.RIGHT.rotated(boss_node.sprite.rotation) * weapon_node.get_rect().size.x / 10, 100)
			current_frame = (current_frame + 1) % frames_between_shots
		else:
			has_attacked = true

func exit() -> void:
	has_attacked = false
	# current_frame = 0

func spin():
	is_spinning = true
	if tween and tween.is_running(): return

	tween = boss_node.create_tween()
	tween.tween_property(boss_node.sprite, "rotation", boss_node.sprite.rotation + TAU * 2, 1)
	tween.connect('finished', _on_tween_finished)
	tween.play()

func _on_tween_finished():
	if tween: tween.kill()
	is_spinning = false
