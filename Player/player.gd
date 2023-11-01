class_name Player
extends CharacterBody2D

@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Node2D = $Sprite
@onready var body_sprite: Sprite2D = $Sprite/Body
@onready var weapon_sprite: Sprite2D = $Sprite/Weapon
@onready var health_bar: HealthBar = $HealthBar
@onready var armor_bar: ProgressBar = $ArmorBar
@onready var armor_regen_timer: Timer = $ArmorRegen
@onready var armor_regen_delay_timer: Timer = $ArmorRegenDelay

var damage_text_scene: PackedScene = load("res://OtherComponents/DamageText/damage_text.tscn")

signal died

const BASE_SPEED: float = 150
const BASE_HP: int = 50
const BASE_ARMOR: int = 20
const SPRINT_SPEED: float = BASE_SPEED * 2

var level: int = 0
var total_hp: int
var total_armor: int
var current_hp: int
var current_armor: int
var damage: int


func _ready():
	armor_bar.update_armor(current_armor, total_armor)
	health_bar.update_health(current_hp, total_hp)
	level_up()

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
		var shoot_direction = (get_global_mouse_position() - global_position).normalized()
		$SingleBulletAttack.shoot_bullet(self, shoot_direction, global_position + shoot_direction * collision.shape.get_rect().size.x * 1.1 + (shoot_direction.orthogonal() * -1))
		$AttackCooldown.start()
	# sound ?
	
	if current_armor < BASE_ARMOR and $ArmorRegenDelay.is_stopped() and $ArmorRegen.is_stopped():
		$ArmorRegen.start()

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
	total_hp = BASE_HP + 10 * (level - 1)
	total_armor = BASE_ARMOR + 2 * (level - 1)
	current_hp = total_hp
	current_armor = total_armor
	damage = level
