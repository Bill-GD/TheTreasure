# For bosses
extends State

@onready var boss_node: BossEnemy = owner as BossEnemy

var tween: Tween
var is_spinning: bool = false
var has_attacked: bool = false
@onready var frames_between_shots: int = max(1, floor(6) / boss_node.level)
var current_frame: int = 0


func enter(_msg := {}):
	# print('Boss chosen attack: Spin')
	has_attacked = false
	spin()

func update(_delta: float) -> void:
	if has_attacked:
		has_attacked = false
		current_frame = 0
		state_machine.transition_to('ChooseAttack')
		return
	else:
		if is_spinning:
			if current_frame == 0:
				boss_node.get_node('ShootSound').play()
				boss_node.get_node('SingleBulletAttack').shoot_bullet(boss_node, Vector2.RIGHT.rotated(boss_node.sprite.rotation), boss_node.global_position + Vector2.RIGHT.rotated(boss_node.sprite.rotation) * boss_node.collision.shape.radius, 100)
			current_frame = (current_frame + 1) % frames_between_shots
		else:
			# await get_tree().create_timer(1 + boss_node.level * 0.2).timeout
			has_attacked = true

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
