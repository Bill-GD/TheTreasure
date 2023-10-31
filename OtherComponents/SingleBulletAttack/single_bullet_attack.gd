extends Node2D

@export var bullet_scene: PackedScene = load("res://Bullet/bullet.tscn")

## Only shoot one bullet in the specified direction.
## Can use multiple times for different directions when shooting multiple bullets.
func shoot_bullet(shooter: CharacterBody2D, shoot_direction: Vector2, target_speed: float = 800.0):
	shoot_direction = shoot_direction.normalized()

	var bullet = bullet_scene.instantiate() as Bullet
	bullet.speed = target_speed
	bullet.position = shooter.global_position + shoot_direction * shooter.collision.shape.get_rect().size.x * 1.1
	bullet.move_direction = shoot_direction

	bullet.shooter = shooter

	get_parent().get_parent().add_child(bullet)