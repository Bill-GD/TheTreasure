class_name Player
extends CharacterBody2D

@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Node2D = $Sprite
@onready var health_bar: HealthBar = $HealthBar
@onready var armor_bar: ProgressBar = $ArmorBar
@onready var armor_regen_timer: Timer = $ArmorRegen
@onready var armor_regen_delay_timer: Timer = $ArmorRegenDelay

var damage_text_scene: PackedScene = load("res://OtherComponents/DamageText/damage_text.tscn")
var death_effect_scene: PackedScene = load("res://OtherComponents/DeathEffect/death_effect.tscn")

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
var damage: int = 0
# 'Pistol', 'Assault', 'Shotgun'
var available_weapons: Array[String] = ['Pistol', 'Assault', 'Shotgun']
var current_weapon: String = 'Pistol'


func _ready() -> void:
	armor_bar.update_armor(current_armor, total_armor)
	health_bar.update_health(current_hp, total_hp)
	level_up()
	$WeaponManager.reset_weapon()

func _physics_process(_delta) -> void:
	# movement
	var direction = Input.get_vector('aswd_left', 'aswd_right', 'aswd_up', 'aswd_down')
	
	velocity = direction * (SPRINT_SPEED if Input.is_key_pressed(KEY_SHIFT) else BASE_SPEED)
	if Input.is_key_pressed(KEY_SHIFT) and velocity != Vector2.ZERO and not $RunSound.playing: $RunSound.play()
	move_and_slide()
	# move_and_collide(velocity * delta)

	# aiming & rotation
	var mouse_direction = (get_global_mouse_position() - global_position).normalized()
	sprite.rotation = mouse_direction.angle()
	collision.rotation = sprite.rotation

	# shooting
	if Input.is_key_pressed(KEY_SPACE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		$WeaponManager.attack(mouse_direction)
	
	if current_armor < BASE_ARMOR and $ArmorRegenDelay.is_stopped() and $ArmorRegen.is_stopped():
		$ArmorRegen.start()

func _on_armor_regen_timeout() -> void:
	current_armor += 1
	armor_bar.update_armor(current_armor, total_armor)
	if current_armor == total_armor: $ArmorRegen.stop()

	var damage_text: DamageText = damage_text_scene.instantiate()
	damage_text.text = '1'
	damage_text.position = global_position
	damage_text.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	get_parent().add_child(damage_text)

func _on_died() -> void:
	var death_effect = death_effect_scene.instantiate()
	death_effect.position = global_position
	get_parent().add_child(death_effect)
	queue_free()

func level_up() -> void:
	level += 1
	total_hp = BASE_HP + 10 * (level - 1)
	total_armor = BASE_ARMOR + 2 * (level - 1)
	current_hp = total_hp
	current_armor = total_armor
	armor_bar.update_armor(current_armor, total_armor)
	health_bar.update_health(current_hp, total_hp)

func heal(amount: int) -> void:
	var actual_heal_amount = min(total_hp - current_hp, amount)
	current_hp += actual_heal_amount
	health_bar.update_health(current_hp, total_hp)

	var damage_text: DamageText = damage_text_scene.instantiate()
	damage_text.text = str(actual_heal_amount)
	damage_text.position = global_position
	damage_text.add_theme_color_override("font_color", Color(0, 1, 0))
	get_parent().add_child(damage_text)
