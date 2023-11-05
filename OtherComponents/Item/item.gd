class_name Item
extends Node2D

var health_sound_scene: PackedScene = load("res://OtherComponents/SoundScenes/health_pickup.tscn")
var item_pickup_sound_scene: PackedScene = load("res://OtherComponents/SoundScenes/item_pickup.tscn")

enum ITEM_TYPE {HEALTH, WEAPON}
var item_type: ITEM_TYPE
var weapon_type: String

func _ready():
	if not item_type is ITEM_TYPE:
		print('Item type invalid')
		queue_free()
	if item_type == ITEM_TYPE.HEALTH:
		$Sprite.play('health')

func _on_area_2d_body_entered(body: Node2D):
	if body is Player:
		match item_type:
			ITEM_TYPE.HEALTH:
				var health_sound = health_sound_scene.instantiate()
				health_sound.position = global_position
				get_parent().add_child(health_sound)
				body.heal(20)
			ITEM_TYPE.WEAPON:
				var item_pickup_sound = item_pickup_sound_scene.instantiate()
				item_pickup_sound.position = global_position
				get_parent().add_child(item_pickup_sound)
		
		queue_free()
