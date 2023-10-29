class_name Enemy
extends KinematicBody2D

const BASE_SPEED: float = 180
const BASE_HP: int = 20
const BASE_DAMAGE: int = 2

var target: Player
var velocity: Vector2
var health: int

func _ready():
    target = get_node("/root/Player")
    health = MAX_HEALTH

func _process(delta):
    if target != null:
        velocity = (target.position - position).normalized() * SPEED
        move_and_slide(velocity)

func take_damage(amount: int):
    health -= amount
    if health <= 0:
        die()

func die():
    # Xử lý khi enemy bị tiêu diệt
    queue_free()
