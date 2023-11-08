extends Node

@export var current_level: Node2D


func _ready() -> void:
	current_level = get_child(1)

func _on_player_died() -> void:
	current_level.stop_all_enemies()
