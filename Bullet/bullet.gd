class_name Bullet
extends RigidBody2D

var move_direction: Vector2 = Vector2.ZERO
const BASE_SPEED: float = 800.0
const BASE_DAMAGE: int = 1

@onready var original_pos: Vector2 = position

# use this to override speed, else use default speed
var speed: float = BASE_SPEED

@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Sprite
var shooter: CharacterBody2D
@onready var actual_damage: int = BASE_DAMAGE + shooter.damage

func _ready():
	# move_direction = move_direction.normalized()
	gravity_scale = 0
	sprite.rotation = move_direction.angle()
	collision.rotation = sprite.rotation + (PI / 2)
	linear_velocity = move_direction * speed
	$DespawnTimer.start()

func _process(_delta):
	if position.distance_to(original_pos) > 1000:
		queue_free()

func _on_despawn_timer_timeout():
	queue_free()
