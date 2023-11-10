class_name Player
extends CharacterBody2D

@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Node2D = $Sprite
@onready var health_bar: HealthBar = $HealthBar
@onready var armor_bar: ProgressBar = $ArmorBar
@onready var armor_regen_timer: Timer = $ArmorRegen
@onready var armor_regen_delay_timer: Timer = $ArmorRegenDelay


@onready var ui_health_bar: HealthBar = get_tree().root.get_node('Game/UI/InGameHud/PlayerBars/MarginContainer/GridContainer/HealthBar')
@onready var ui_armor_bar: ProgressBar = get_tree().root.get_node('Game/UI/InGameHud/PlayerBars/MarginContainer/GridContainer/ArmorBar')

var damage_text_scene: PackedScene = preload("res://OtherComponents/DamageText/damage_text.tscn")
var death_effect_scene: PackedScene = preload("res://OtherComponents/DeathEffect/death_effect.tscn")

signal died

const BASE_SPEED: float = 180
const BASE_HP: int = 40
const BASE_ARMOR: int = 10
const SPRINT_SPEED: float = BASE_SPEED * 2
const BASE_DAMAGE: int = 1

var level: int = 0
var total_hp: int
var total_armor: int
var current_hp: int
var current_armor: int
var damage: int = 0
# 'Pistol', 'Shotgun', 'Assault'
var available_weapons: Array[String] = ['Pistol']
var current_weapon: String = 'Pistol'


func _ready() -> void:
	update_health_displays()
	update_armor_displays()
	level_up()
	$WeaponManager.reset_weapon()
	update_weapon_displays()

func _physics_process(_delta) -> void:
	# movement
	var direction = Input.get_vector('aswd_left', 'aswd_right', 'aswd_up', 'aswd_down')
	
	velocity = direction * (SPRINT_SPEED if Input.is_key_pressed(KEY_SHIFT) else BASE_SPEED)
	if Input.is_key_pressed(KEY_SHIFT) and velocity != Vector2.ZERO:
		if not $RunSound.playing: $RunSound.play()
		$RunParticle.emitting = true
	else: $RunParticle.emitting = false

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
	update_armor_displays()
	if current_armor >= total_armor:
		current_armor = total_armor
		$ArmorRegen.stop()
		
	add_popup_text('1', Color(0.7, 0.7, 0.7))

func _on_died() -> void:
	var death_effect = death_effect_scene.instantiate()
	death_effect.position = global_position
	get_parent().add_child(death_effect)
	queue_free()

func level_up() -> void:
	level += 1
	total_hp = BASE_HP + 10 * (level - 1)
	total_armor = BASE_ARMOR + 4 * (level - 1)
	current_hp = total_hp
	current_armor = total_armor
	update_armor_displays()
	update_health_displays()

func heal(amount: int) -> void:
	var actual_heal_amount = min(total_hp - current_hp, amount)
	current_hp += actual_heal_amount
	update_health_displays()

	var damage_text: DamageText = damage_text_scene.instantiate()
	damage_text.text = str(actual_heal_amount)
	damage_text.position = global_position
	damage_text.add_theme_color_override("font_color", Color(0, 1, 0))
	get_parent().add_child(damage_text)

func add_popup_text(new_text: String, color: Color) -> void:
	var damage_text: DamageText = damage_text_scene.instantiate()
	damage_text.text = new_text
	damage_text.position = global_position
	damage_text.add_theme_color_override("font_color", color)
	get_parent().add_child(damage_text)

func update_health_displays() -> void:
	health_bar.update_health(current_hp, total_hp)
	ui_health_bar.update_health(current_hp, total_hp)
	ui_health_bar.get_node('Label').text = '%s / %s' % [current_hp, total_hp]

func update_armor_displays() -> void:
	armor_bar.update_armor(current_armor, total_armor)
	ui_armor_bar.update_armor(current_armor, total_armor)
	ui_armor_bar.get_node('Label').text = '%s / %s' % [current_armor, total_armor]

func update_weapon_displays() -> void:
	var weapon_display: Control = get_tree().root.get_node('Game/UI/InGameHud/WeaponDisplay/MarginContainer/HBoxContainer')
	for i in range(3):
		if i < available_weapons.size():
			weapon_display.get_child(i).get_node('WeaponName').text = available_weapons[i]
		else:
			weapon_display.get_child(i).get_node('WeaponName').text = 'Empty'
