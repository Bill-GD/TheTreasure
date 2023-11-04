extends Sprite2D

var damage: int = 2
var fire_rate: float = 0.8

func shoot(shoot_direction: Vector2) -> void:
	var player: Player = get_parent().get_parent()
	
	$SingleBulletAttack.shoot_bullet(player, shoot_direction, global_position + shoot_direction * get_rect().size.x / 5 + (shoot_direction.orthogonal() * -1.8))
	$SingleBulletAttack.shoot_bullet(player, shoot_direction, global_position + shoot_direction * get_rect().size.x / 5 + (shoot_direction.orthogonal() * 0.4))