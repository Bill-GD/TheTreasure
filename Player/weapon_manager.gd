extends Node2D

@onready var player: Player = get_parent()

@onready var pistol_scene: PackedScene = preload("res://Player/Weapons/pistol.tscn")
@onready var shotgun_scene: PackedScene = preload("res://Player/Weapons/shotgun.tscn")
@onready var assault_rifle_scene: PackedScene = preload("res://Player/Weapons/assault_rifle.tscn")


func _process(_delta):
	if Input.is_key_pressed(KEY_1): change_weapon('Pistol')
	if Input.is_key_pressed(KEY_2): change_weapon('Shotgun')
	if Input.is_key_pressed(KEY_3): change_weapon('Assault')

func change_weapon(new_weapon_name: String) -> void:
	# var player: Player = get_parent()
	if new_weapon_name != player.current_weapon and new_weapon_name in player.available_weapons and $WeaponSwapCooldown.is_stopped():
		var current_weapon_node: Sprite2D = player.get_node('Sprite').get_children()[1]
		var new_weapon_node: Sprite2D

		if new_weapon_name == 'Pistol': new_weapon_node = pistol_scene.instantiate()
		if new_weapon_name == 'Shotgun': new_weapon_node = shotgun_scene.instantiate()
		if new_weapon_name == 'Assault': new_weapon_node = assault_rifle_scene.instantiate()
			
		new_weapon_node.position = current_weapon_node.position
		new_weapon_node.rotation = current_weapon_node.rotation
		$AttackCooldown.wait_time = new_weapon_node.fire_rate

		$WeaponSwapCooldown.start()

		player.get_node('Sprite').remove_child(current_weapon_node)
		player.get_node('Sprite').add_child(new_weapon_node)

		player.damage = new_weapon_node.damage
		player.current_weapon = new_weapon_name

func attack(shoot_direction: Vector2) -> void:
	if $AttackCooldown.is_stopped():
		get_parent().get_node('Sprite').get_children()[1].shoot(shoot_direction)
		$AttackCooldown.start()

func reset_weapon() -> void:
	change_weapon('Pistol')
