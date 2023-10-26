extends CharacterBody2D

@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Sprite

var bullet_scene: PackedScene = load("res://Bullet/bullet.tscn")

const BASE_SPEED: float = 150
const BASE_HP: int = 20
const BASE_ARMOR: int = 10
const SPRINT_SPEED: float = BASE_SPEED * 2

@onready var current_hp: int = BASE_HP
@onready var current_armor: int = BASE_ARMOR

func _physics_process(_delta):
	# movement
	var direction = Input.get_vector('aswd_left', 'aswd_right', 'aswd_up', 'aswd_down')
	
	velocity = direction * (SPRINT_SPEED if Input.is_key_pressed(KEY_SHIFT) else BASE_SPEED)
	move_and_slide()

	# collision

	# aiming & rotation
	sprite.rotation = (get_global_mouse_position() - global_position).angle()
	collision.rotation = sprite.rotation

	# shooting
	if $AttackCooldown.is_stopped() and (Input.is_key_pressed(KEY_SPACE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		shoot_bullet()
		$AttackCooldown.start()
	# sound ?

func shoot_bullet():
	var shoot_direction: Vector2 = (get_global_mouse_position() - position).normalized()

	var bullet = bullet_scene.instantiate()
	bullet.position = position + shoot_direction * 10
	bullet.move_direction = shoot_direction

	get_parent().add_child(bullet)
