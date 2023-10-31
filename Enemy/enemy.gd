class_name Enemy
extends CharacterBody2D

@onready var health_bar: ProgressBar = $HealthBar
@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Sprite

signal died

const BASE_SPEED: float = 100
const BASE_HP: int = 20
const BASE_DAMAGE: int = 2

var target: Player
var level: int = 1
var total_hp: int = BASE_HP * level
var current_hp: int = total_hp * level
var damage: int = BASE_DAMAGE * level
var player_detected: bool = false
var player_close_range: bool = false


func _ready():
	target = get_parent().get_node("Player")
	health_bar.update_health(current_hp, total_hp)
	$Enemy_PlayerDetection.connect('player_detection_changed', _on_player_detection_changed)
	velocity = Vector2.ZERO

func _process(_delta):
	if target != null:
		velocity = (target.position - position).normalized() * BASE_SPEED if player_detected else Vector2.ZERO
		move_and_slide()

	if current_hp <= 0:
		died.emit()

	sprite.flip_h = velocity.x > 0
	
	if player_detected and $AttackCooldown.is_stopped():
		$SingleBulletAttack.shoot_bullet(self, target.global_position - global_position)
		$AttackCooldown.start()

# func take_damage(amount: int):
# 	current_hp -= amount
# 	if current_hp <= 0:
# 		die()

func _on_died():
	queue_free()

func _on_player_detection_changed():
	pass
