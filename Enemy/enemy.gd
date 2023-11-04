class_name Enemy
extends CharacterBody2D

@onready var health_bar: ProgressBar = $HealthBar
@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Sprite
@onready var nav_agent: NavigationAgent2D = $EnemyNavigation

var death_effect_scene: PackedScene = load("res://OtherComponents/DeathEffect/death_effect.tscn")

signal died

var target: Player

const BASE_SPEED: float = 100
const BASE_HP: int = 60
const BASE_DAMAGE: int = 2

var move_direction: Vector2
var target_direction: Vector2
var level: int = 1
var total_hp: int = BASE_HP * level
var current_hp: int = total_hp * level
var damage: int = BASE_DAMAGE * level
var player_detected: bool = false
var player_close_range: bool = false
var has_seen_player: bool = false


func _ready():
	target = get_parent().get_node("Player")
	health_bar.update_health(current_hp, total_hp)
	$Enemy_PlayerDetection.connect('player_detection_changed', _on_player_detection_changed)
	velocity = Vector2.ZERO

func _process(_delta):
	if target:
		if player_detected:
			target_direction = (target.global_position - global_position).normalized()
			move_direction = target_direction
		elif not has_seen_player: move_direction = Vector2.ZERO
		else:
			move_direction = (nav_agent.get_next_path_position() - position).normalized()
	else: target_direction = Vector2.ZERO

	if current_hp <= 0:
		died.emit()

	# sprite.flip_h = velocity.x > 0
	
	if player_detected and $AttackCooldown.is_stopped():
		$SingleBulletAttack.shoot_bullet(self, target.global_position - global_position)
		$AttackCooldown.start()
	if player_close_range:
		move_direction = (target.global_position - global_position).orthogonal().normalized()

	velocity = move_direction * BASE_SPEED
	move_and_slide()

# func take_damage(amount: int):
# 	current_hp -= amount
# 	if current_hp <= 0:
# 		die()

func _on_died():
	var death_effect = death_effect_scene.instantiate()
	death_effect.position = global_position
	get_parent().add_child(death_effect)
	queue_free()

func _on_player_detection_changed():
	pass
