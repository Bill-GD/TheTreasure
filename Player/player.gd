class_name Player
extends CharacterBody2D

@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Sprite
@onready var health_bar: HealthBar = $HealthBar
@onready var armor_bar: ProgressBar = $ArmorBar
@onready var armor_regen_timer: Timer = $ArmorRegen
@onready var armor_regen_delay_timer: Timer = $ArmorRegenDelay

@export var bullet_scene: PackedScene = load("res://Bullet/bullet.tscn")
var damage_text_scene: PackedScene = load("res://OtherComponents/DamageText/damage_text.tscn")

signal died

const BASE_SPEED: float = 150
const BASE_HP: int = 50
const BASE_ARMOR: int = 20
const SPRINT_SPEED: float = BASE_SPEED * 2

var level: int = 1
var total_hp: int = BASE_HP + 10 * (level - 1)
var total_armor: int = BASE_ARMOR + 2 * (level - 1)

@onready var current_hp: int = total_hp
@onready var current_armor: int = total_armor
@onready var damage: int = level

func _ready():
	armor_bar.update_armor(current_armor, total_armor)
	health_bar.update_health(current_hp, total_hp)
	# health_bar.font_color = Color(0, 1, 0, 1)
	# print(collision.shape.get_rect().size)

func _physics_process(delta):
	# movement
	var direction = Input.get_vector('aswd_left', 'aswd_right', 'aswd_up', 'aswd_down')
	
	velocity = direction * (SPRINT_SPEED if Input.is_key_pressed(KEY_SHIFT) else BASE_SPEED)
	# move_and_slide()
	move_and_collide(velocity * delta)

	# aiming & rotation
	sprite.rotation = (get_global_mouse_position() - global_position).angle()
	collision.rotation = sprite.rotation

	# shooting
	if $AttackCooldown.is_stopped() and (Input.is_key_pressed(KEY_SPACE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		shoot_bullet()
		$AttackCooldown.start()
	# sound ?
	
	if current_armor < BASE_ARMOR and $ArmorRegenDelay.is_stopped() and $ArmorRegen.is_stopped():
		$ArmorRegen.start()

func shoot_bullet():
	var shoot_direction: Vector2 = (get_global_mouse_position() - position).normalized()

	var bullet = bullet_scene.instantiate() as RigidBody2D
	bullet.position = position + shoot_direction * collision.shape.get_rect().size.x * 1.1
	bullet.move_direction = shoot_direction

	# bullet.set_collision_mask_value(2, true)
	bullet.shooter = self

	get_parent().add_child(bullet)

func _on_armor_regen_timeout():
	current_armor += 1
	armor_bar.update_armor(current_armor, BASE_ARMOR)
	if current_armor == BASE_ARMOR: $ArmorRegen.stop()

	var damage_text: DamageText = damage_text_scene.instantiate()
	damage_text.text = '1'
	damage_text.position = global_position
	damage_text.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	get_parent().add_child(damage_text)

func _on_died():
	queue_free()

func level_up():
	level += 1
	total_hp= BASE_HP + 10 * (level - 1)
	total_armor = BASE_ARMOR + 2 * (level - 1)
	current_hp = total_hp
	current_armor = total_armor
	damage = level
