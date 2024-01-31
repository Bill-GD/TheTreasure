extends Sprite2D

var damage: int = 3
var fire_rate: float = 0.35

func shoot(shoot_direction: Vector2) -> void:
	$SoundEffect.play()

	$SingleBulletAttack.shoot_bullet(get_parent().get_parent(), shoot_direction, global_position + shoot_direction * get_rect().size.x / 20 + (shoot_direction.orthogonal() * -1))
