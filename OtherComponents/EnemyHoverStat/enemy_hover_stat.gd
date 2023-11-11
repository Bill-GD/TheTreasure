class_name EnemyHoverStat
extends Label

func _process(_delta):
	global_position = get_global_mouse_position() + Vector2.RIGHT * 5