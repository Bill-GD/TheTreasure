class_name BossEnemy
extends CharacterBody2D

@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Sprite
@onready var health_bar: ProgressBar = $HealthBar
@onready var nav_agent: NavigationAgent2D = $EnemyNavigation

var death_effect_scene: PackedScene = load("res://OtherComponents/DeathEffect/death_effect.tscn")
var item_scene: PackedScene = load("res://OtherComponents/Item/item.tscn")

signal died

const BASE_SPEED: float = 150
const BASE_HP: int = 200
const BASE_DAMAGE: int = 6

var tween: Tween
var target: Player

var level: int = 1
@onready var damage: int = BASE_DAMAGE * level
@onready var total_hp: int = BASE_HP * level
@onready var current_hp: int = total_hp
var speed: float = BASE_SPEED

var is_attacking: bool = false
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

	$PlayerDetection.connect('player_detection_changed', _on_player_detection_changed)
	move_direction = Vector2.ZERO

func _physics_process(_delta):
	velocity = move_direction.normalized() * speed
	move_and_slide()

	if current_hp <= 0:
		died.emit()

# func _on_attack_timer_timeout():
# 	is_attacking = true
# 	await get_tree().create_timer(0.2).timeout

# 	if current_attack == ATTACKS.SHOOT_NORMAL or current_attack == ATTACKS.SHOOT_SPREAD:
# 		velocity = (target.global_position - global_position).normalized() * (speed / 3) * (level - 1)
# 		# attack()
# 		is_attacking = false
# 		$AttackCooldown.start()

func _on_died():
	var health_item: Item = item_scene.instantiate()
	health_item.position = global_position + Vector2.UP.rotated(randf_range(-PI, PI)) * 5
	health_item.item_type = Item.ITEM_TYPE.HEALTH
	get_parent().add_child(health_item)
	
	if level <= 2:
		var weapon_item: Item = item_scene.instantiate()
		weapon_item.position = global_position + Vector2.UP.rotated(randf_range(-PI, PI)) * 5
		weapon_item.item_type = Item.ITEM_TYPE.WEAPON
		match level:
			1: weapon_item.weapon_type = 'Shotgun'
			2: weapon_item.weapon_type = 'Assault'
		get_parent().add_child(weapon_item)

	var death_effect = death_effect_scene.instantiate()
	death_effect.position = global_position
	get_parent().add_child(death_effect)

	queue_free()

func _on_player_detection_changed():
	if player_in_detect_range and not player_close_range: speed = BASE_SPEED * 2
	elif player_close_range: speed = BASE_SPEED

	if not player_in_detect_range: available_attacks = []
	if player_close_range:
		match level:
			1: available_attacks = ['SHOOT_NORMAL', 'SHOOT_SPREAD', 'SPIN']
			2: available_attacks = ['SHOOT_NORMAL', 'SHOOT_SPREAD', 'SPIN']
			3: available_attacks = ['SHOOT_NORMAL', 'SHOOT_SPREAD', 'SPIN']
