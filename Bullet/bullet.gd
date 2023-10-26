extends RigidBody2D

var move_direction: Vector2 = Vector2.ZERO
const BASE_SPEED: float = 800.0

# use this to override speed, else use default speed
var speed: float = BASE_SPEED

@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Sprite

func _ready():
	# move_direction = move_direction.normalized()
	gravity_scale = 0
	collision.rotation = move_direction.angle()
	sprite.rotation = collision.rotation
	linear_velocity = move_direction * speed

# func _process(_delta):
# 	print(collision.rotation)

func _on_visible_on_screen_notifier_2d_screen_exited():
	# queue_free()
	pass
