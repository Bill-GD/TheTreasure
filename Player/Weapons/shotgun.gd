extends Sprite2D

var damage: int = 3
var fire_rate: float = 0.6

func shoot(shoot_direction: Vector2) -> void:
	var player: Player = get_parent().get_parent()

	$SoundEffect.play()
	
	$SingleBulletAttack.shoot_bullet(player, Vector2.RIGHT.rotated(shoot_direction.angle() + (PI / 90)), global_position + shoot_direction * get_rect().size.x / 5 + (shoot_direction.orthogonal() * -1.8))
	$SingleBulletAttack.shoot_bullet(player, Vector2.RIGHT.rotated(shoot_direction.angle() - (PI / 90)), global_position + shoot_direction * get_rect().size.x / 5 + (shoot_direction.orthogonal() * 0.4))
