class_name BossEnemy
extends CharacterBody2D

@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Sprite
@onready var health_bar: ProgressBar = $HealthBar
@onready var nav_agent: NavigationAgent2D = $EnemyNavigation

var death_effect_scene: PackedScene = load("res://OtherComponents/DeathEffect/death_effect.tscn")
var item_scene: PackedScene = load("res://OtherComponents/Item/item.tscn")

signal died

var target: Player

const BASE_SPEED: float = 150
const BASE_HP: int = 200
const BASE_DAMAGE: int = 7

var tween: Tween

var level: int = 1
var damage: int = BASE_DAMAGE * level
var total_hp: int = BASE_HP * level
var current_hp: int = total_hp
var speed: float = BASE_SPEED

var is_aiming: bool = false
var is_attacking: bool = false
var pos_before_dash: Vector2
var move_direction: Vector2

var player_in_detect_range: bool = false
var player_close_range: bool = false
var has_seen_player: bool = false
var lost_player: bool = true

enum ATTACKS {
	SHOOT_NORMAL,
	SHOOT_SPREAD,
	SPIN,
}
var current_attack: ATTACKS
var available_attacks = []


func _ready():
	health_bar.update_health(current_hp, total_hp)

	target = get_parent().get_node('Player')
	$AttackCooldown.start()

	$PlayerDetection.connect('player_detection_changed', _on_player_detection_changed)
	move_direction = Vector2.ZERO

func _physics_process(_delta):
	# if target:
	# 	if not has_seen_player: move_direction = Vector2.ZERO
	# 	else:

	# 		if lost_player: # if seen, lost -> pathfind
	# 			move_direction = nav_agent.get_next_path_position() - position
	# 			sprite.rotation = move_direction.angle()
	# 		else: # if seen, not lost
	# 			if player_in_detect_range and not player_close_range and not is_attacking: # if seen, not lost, not close, not attacking -> chase
	# 				move_direction = target.global_position - global_position
	# 				sprite.rotation = move_direction.angle()
	# 			elif player_close_range:
	# 				move_direction = Vector2.ZERO
	# 				if is_aiming: sprite.rotation = (target.global_position - global_position).angle()
	# 				if is_attacking:
	# 					if player_close_range and current_attack == ATTACKS.SPIN:
	# 						spin()
	# 						attack()
	# else: move_direction = Vector2.ZERO

	velocity = move_direction.normalized() * speed
	move_and_slide()

	if current_hp <= 0:
		died.emit()

func _on_attack_timer_timeout():
	is_attacking = true
	is_aiming = false
	pos_before_dash = global_position
	await get_tree().create_timer(0.2).timeout

	if current_attack == ATTACKS.SHOOT_NORMAL or current_attack == ATTACKS.SHOOT_SPREAD:
		velocity = (target.global_position - global_position).normalized() * (speed / 3) * (level - 1)
		attack()
		is_attacking = false
		$AttackCooldown.start()

func _on_attack_cooldown_timeout():
	if len(available_attacks) <= 0: 
		$AttackCooldown.start()
		return
	current_attack = ATTACKS[available_attacks[randi() % len(available_attacks)]]
	$AttackTimer.start()
	is_aiming = true

func attack():
	var shoot_direction: Vector2 = (target.global_position - global_position).normalized()
	$ShootSound.play()

	if current_attack == ATTACKS.SHOOT_SPREAD:
		$SingleBulletAttack.shoot_bullet(self, shoot_direction)
		$SingleBulletAttack.shoot_bullet(self, Vector2.RIGHT.rotated(shoot_direction.angle() + -PI/12).normalized())
		$SingleBulletAttack.shoot_bullet(self, Vector2.RIGHT.rotated(shoot_direction.angle() + PI/12).normalized())
	elif current_attack == ATTACKS.SPIN:
		$SingleBulletAttack.shoot_bullet(self, Vector2.RIGHT.rotated(sprite.rotation), global_position + Vector2.RIGHT.rotated(sprite.rotation) * collision.shape.radius, 100)
	else:
		$SingleBulletAttack.shoot_bullet(self, shoot_direction)

func spin():
	if tween and tween.is_running(): return

	tween = create_tween()
	tween.tween_property(sprite, "rotation", sprite.rotation + TAU * 2, 1)
	tween.connect('finished', _on_tween_finished)
	tween.play()

func _on_tween_finished():
	if tween: tween.kill()
	is_attacking = false
	$AfterSpinCooldown.start()

func _on_died():
	var health_item: Item = item_scene.instantiate()
	health_item.position = global_position
	health_item.item_type = Item.ITEM_TYPE.HEALTH
	get_tree().root.add_child(health_item)

	var death_effect = death_effect_scene.instantiate()
	death_effect.position = global_position
	get_parent().add_child(death_effect)

	queue_free()

func _on_player_detection_changed():
	if player_in_detect_range and not player_close_range: speed = BASE_SPEED * 2
	elif player_close_range: speed = BASE_SPEED

	if not player_in_detect_range: available_attacks = []
	if player_close_range: available_attacks = ['SHOOT_NORMAL', 'SHOOT_SPREAD', 'SPIN']
