class_name Bullet
extends RigidBody2D

@onready var collision: CollisionShape2D = $Collision
@onready var sprite: AnimatedSprite2D = $Sprite

var damage_text_scene: PackedScene = load("res://OtherComponents/DamageText/damage_text.tscn")
var damage_impact_scene: PackedScene = load("res://Bullet/bullet_impact.tscn")
var hit_wall_sound_scene: PackedScene = load("res://OtherComponents/SoundScenes/hit_wall_sound.tscn")

signal hit_entity
signal hit_wall

const BASE_SPEED: float = 1000.0
const BASE_DAMAGE: int = 1

## Use this to override speed, else use default speed.
var speed: float = BASE_SPEED
var shooter: CharacterBody2D
var move_direction: Vector2 = Vector2.ZERO
@onready var actual_damage: int = BASE_DAMAGE + shooter.damage
@onready var original_pos: Vector2 = position


func _ready():
	# move_direction = move_direction.normalized()
	sprite.play()
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

func _on_hit_entity():
	var damage_text: DamageText = damage_text_scene.instantiate()

	damage_text.text = str(actual_damage)
	damage_text.position = global_position
	damage_text.add_theme_color_override("font_color", Color(1, 0, 0))

	var damage_impact = damage_impact_scene.instantiate()
	damage_impact.position = global_position

	get_parent().add_child(damage_text)
	get_parent().add_child(damage_impact)
	queue_free()

func _on_hit_wall():
	if shooter != null and shooter is Player:
		var hit_wall_sound = hit_wall_sound_scene.instantiate()
		hit_wall_sound.position = global_position
		get_parent().add_child(hit_wall_sound)
	queue_free()

func _on_body_entered(body: Node):
	if body.is_in_group('wall'):
		hit_wall.emit()
