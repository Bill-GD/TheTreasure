extends Node2D

@onready var player: Player = get_parent()
@onready var player_weapon_sprite: Sprite2D = get_parent().get_node('Sprite/Weapon')
@onready var attack_cooldown_timer: Timer = $AttackCooldown

@onready var pistol_texture = preload("res://Assets/pistol.png")
@onready var shotgun_texture = preload("res://Assets/shotgun.png")
@onready var assault_rifle_texture = preload("res://Assets/assault_rifle.png")

var current_weapon: String = 'Pistol'


func change_weapon(new_weapon: String) -> void:
	# var player: Player = get_parent()
	if $WeaponSwapCooldown.is_stopped() and new_weapon in player.available_weapons:
		current_weapon = new_weapon

		if current_weapon == 'Pistol':
			attack_cooldown_timer.wait_time = 0.5
			player_weapon_sprite.texture = pistol_texture

		if current_weapon == 'Shotgun':
			attack_cooldown_timer.wait_time = 1
			player_weapon_sprite.texture = shotgun_texture

		if current_weapon == 'Assault':
			attack_cooldown_timer.wait_time = 0.1
			player_weapon_sprite.texture = assault_rifle_texture
		
		player.current_weapon = (player.current_weapon + 1) % 3
		$WeaponSwapCooldown.start()

func attack(shoot_direction: Vector2) -> void:
	if $AttackCooldown.is_stopped():
		# var player: Player = get_parent()
		if current_weapon == 'Pistol' or current_weapon == 'Assault':
			$SingleBulletAttack.shoot_bullet(player, shoot_direction, player.global_position + shoot_direction * player.collision.shape.radius * 1.2 + (shoot_direction.orthogonal() * -1))
		if current_weapon == 'Shotgun':
			$SingleBulletAttack.shoot_bullet(player, shoot_direction, player.global_position + shoot_direction * player.collision.shape.radius * 1.2 + (shoot_direction.orthogonal() * -1.8))
			$SingleBulletAttack.shoot_bullet(player, shoot_direction, player.global_position + shoot_direction * player.collision.shape.radius * 1.2 + (shoot_direction.orthogonal() * 0.4))
		$AttackCooldown.start()

func reset_weapon() -> void:
	change_weapon('Pistol')
