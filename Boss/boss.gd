class_name BossEnemy
extends CharacterBody2D

@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Sprite
@onready var health_bar: ProgressBar = $HealthBar
var tween: Tween

@export var player: Player
var bullet_scene: PackedScene = load("res://Bullet/bullet.tscn")

signal died

const BASE_SPEED: float = 150
const BASE_HP: int = 200
const BASE_DAMAGE: int = 5

var level: int = 1
@onready var damage: int = BASE_DAMAGE * level
@onready var total_hp: int = BASE_HP * level
@onready var current_hp: int = total_hp

var is_attacking: bool = false
var is_aiming: bool = false
var pos_before_attack: Vector2
# var collision_count: int = 0

var player_detected: bool = false
var player_close_range: bool = false

enum ATTACKS {
	DASH,
	SHOOT_NORMAL,
	SHOOT_SPREAD,
	SPIN,
}
var current_attack: ATTACKS
var available_attacks = []

func _ready():
	print(current_hp)
	health_bar.update_health(current_hp, total_hp)

	print(available_attacks)
	player = get_parent().get_node('Player') as Player
	$AttackCooldown.start()

func _physics_process(delta):
	# movement: navigation or custom movement
	# move_and_slide()
	var collision_detected = move_and_collide(velocity * delta)

	# collision
	# collision_count = 0
	# while collision_detected and collision_count < 3:
	# 	var collider = collision.get_collider() as Node2D
	# 	print('boss has collision')
	# 	if collider is Bullet:
	# 		current_hp -= 1
	# 		health_bar.update_health(current_hp, BASE_HP)
	# 		collider.queue_free()
	# 		break
	# 	else: collision_count += 1
	
	# collision

	# aiming & rotation -> get player position

	# attacking
	# if player_detected:
	if is_aiming:
		sprite.rotation = (player.global_position - global_position).angle()
		collision.rotation = sprite.rotation
		# look_at(player.global_position)
	if is_attacking:
		if current_attack == ATTACKS.DASH and (get_last_slide_collision() or (global_position - pos_before_attack).length() > 200):
			velocity = Vector2.ZERO
			is_attacking = false
			$AttackCooldown.start()
		if current_attack == ATTACKS.SPIN:
			velocity = Vector2.ZERO
			spin()
			shoot_bullet()
	# sound ?

	if current_hp <= 0:
		died.emit()

func prepare_attack():
	$AttackTimer.start()
	is_aiming = true

func _on_attack_timer_timeout():
	is_attacking = true
	is_aiming = false
	pos_before_attack = global_position
	await get_tree().create_timer(0.2).timeout

	if current_attack == ATTACKS.DASH:
		velocity = Vector2.RIGHT.rotated(sprite.rotation) * BASE_SPEED * 10
	if current_attack == ATTACKS.SHOOT_NORMAL or current_attack == ATTACKS.SHOOT_SPREAD:
		velocity = (player.global_position - global_position).normalized() * 30 * (level - 1)
		shoot_bullet()
		is_attacking = false
		$AttackCooldown.start()

func _on_attack_cooldown_timeout():
	if len(available_attacks) <= 0: 
		$AttackCooldown.start()
		return
	current_attack = ATTACKS[available_attacks[randi() % len(available_attacks)]]
	# current_attack = ATTACKS.SPIN
	# print(ATTACKS.keys()[current_attack])
	prepare_attack()

func shoot_bullet():
	var bullets = []
	var shoot_direction: Vector2 = (player.global_position - global_position).normalized()

	if current_attack == ATTACKS.SHOOT_SPREAD:
		for i in range(3):
			var bullet = bullet_scene.instantiate()
			bullets.append(bullet)
		bullets[0].move_direction = shoot_direction
		bullets[1].move_direction = Vector2.RIGHT.rotated(shoot_direction.angle() + -PI/12).normalized()
		bullets[2].move_direction = Vector2.RIGHT.rotated(shoot_direction.angle() + PI/12).normalized()
	elif current_attack == ATTACKS.SPIN:
		var bullet = bullet_scene.instantiate()
		shoot_direction = Vector2.RIGHT.rotated(sprite.rotation)
		bullet.move_direction = shoot_direction
		bullet.speed = 100
		bullets.append(bullet)
	else:
		var bullet = bullet_scene.instantiate()
		bullet.move_direction = shoot_direction
		bullets.append(bullet)
	
	for bullet in bullets:
		bullet.position = position + shoot_direction * collision.shape.get_rect().size.x
		# bullet.set_collision_mask_value(1, true)
		bullet.shooter = self
		get_parent().add_child(bullet)

func spin():
	if tween and tween.is_running(): return

	tween = create_tween()
	tween.tween_property(sprite, "rotation", sprite.rotation + TAU * 2, 1)
	tween.connect('finished', _on_tween_finished)
	tween.play()


func _on_tween_finished():
	# print('tween finished')
	if tween: tween.kill()
	is_attacking = false
	$AfterSpinCooldown.start()

func _on_detect_range_body_entered(body: Node2D):
	if player_close_range:
		player_detected = true
		return
	player_detected = body is Player
	available_attacks = ['DASH']

func _on_detect_range_body_exited(body: Node2D):
	player_detected = not (body is Player)
	available_attacks = []

func _on_close_range_body_entered(body: Node2D):
	player_close_range = body is Player
	available_attacks = ['SHOOT_NORMAL', 'SHOOT_SPREAD', 'SPIN']

func _on_close_range_body_exited(body: Node2D):
	player_close_range = not (body is Player)
	available_attacks = ['DASH']

func _on_died():
	queue_free()

func _on_hurt_box_body_entered(body: Node2D):
	if body is Bullet:
		current_hp -= body.actual_damage
		health_bar.update_health(current_hp, total_hp)
		print('Boss HP: %s' % current_hp)
	body.queue_free()
