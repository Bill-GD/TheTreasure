class_name Enemy
extends CharacterBody2D

@onready var health_bar: ProgressBar = $HealthBar

const BASE_SPEED: float = 180
const BASE_HP: int = 20
const BASE_DAMAGE: int = 2
const MAX_HEALTH: int = 20

var target: Player
# var velocity: Vector2
var health: int

func _ready():
    target = get_node("../Player/player.tscn")
    health = MAX_HEALTH
    health_bar.update_health(health, MAX_HEALTH)

func _process(_delta):
    if target != null:
        velocity = (target.position - position).normalized() * BASE_SPEED
        move_and_slide()

func take_damage(amount: int):
    health -= amount
    if health <= 0:
        die()

func die():
    # Xử lý khi enemy bị tiêu diệt
    queue_free()

func _on_hurt_box_body_entered(body: Node2D):
    if body is Bullet and body.shooter is Player:
        take_damage(body.actual_damage)

        health_bar.update_health(health, MAX_HEALTH)
        body.queue_free()
