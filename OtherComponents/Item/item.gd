class_name Item
extends Node2D

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
		if item_type == ITEM_TYPE.HEALTH: body.heal(20)
		if item_type == ITEM_TYPE.WEAPON: pass
		
		queue_free()
