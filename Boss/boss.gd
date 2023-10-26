extends CharacterBody2D

const BASE_SPEED: float = 150
const BASE_HP: int = 200

var is_attacking: bool = false
var is_aiming: bool = false
var pos_before_attack: Vector2

@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Sprite

@export var player: CharacterBody2D
var bullet_scene: PackedScene = load("res://Bullet/bullet.tscn")

enum ATTACKS {DASH, SHOOT_NORMAL, SHOOT_SPREAD}
var current_attack: ATTACKS

func _ready():
	player = get_parent().get_node('Player') as CharacterBody2D
	$AttackCooldown.start()

func _physics_process(_delta):
	# movement: navigation or custom movement
	move_and_slide()

	# collision

	# aiming & rotation -> get player position

	# attacking
	if is_aiming:
		sprite.rotation = (player.global_position - global_position).angle()
		collision.rotation = sprite.rotation
		# look_at(player.global_position)
	if is_attacking:
		if current_attack == ATTACKS.DASH and (get_last_slide_collision() or (global_position - pos_before_attack).length() > 500):
			velocity = Vector2.ZERO
			is_attacking = false
			$AttackCooldown.start()

	# sound ?

	pass

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
		shoot_bullet()
		is_attacking = false
		$AttackCooldown.start()

func _on_attack_cooldown_timeout():
	current_attack = randi() % len(ATTACKS.keys()) as ATTACKS
	print(ATTACKS.keys()[current_attack])
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
	else:
		var bullet = bullet_scene.instantiate()
		bullet.move_direction = shoot_direction
		bullets.append(bullet)
	
	for bullet in bullets:
		bullet.position = position + shoot_direction * 10
		get_parent().add_child(bullet)
