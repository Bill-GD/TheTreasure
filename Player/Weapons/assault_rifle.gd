extends Sprite2D

var damage: int = 2
var fire_rate: float = 0.1

func shoot(shoot_direction: Vector2) -> void:
	$SingleBulletAttack.shoot_bullet(get_parent().get_parent(), shoot_direction, global_position + shoot_direction * get_rect().size.x / 10 + (shoot_direction.orthogonal() * -0.2))
