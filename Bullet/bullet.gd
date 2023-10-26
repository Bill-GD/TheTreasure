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

func _on_visible_on_screen_notifier_2d_screen_exited():
	# queue_free()
	pass

func _on_body_entered(body):
	var actual_damage: int = BASE_DAMAGE + body.damage
	if body is BossEnemy:
		body.current_hp -= actual_damage
		body.health_bar.update_health(body.current_hp, body.total_hp)
	if body is Player:
		if body.current_armor > 0:
			body.current_armor -= actual_damage
			body.armor_bar.update_armor(body.current_armor, body.BASE_ARMOR)
		else: body.current_hp -= actual_damage
			
		body.armor_regen_timer.stop()
		body.armor_regen_delay_timer.start()

		body.health_bar.update_health(body.current_hp, body.BASE_HP)
	queue_free()


func _on_despawn_timer_timeout():
	queue_free()
