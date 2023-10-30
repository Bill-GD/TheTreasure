extends Node2D

@export var boss_scene: PackedScene = load("res://Enemy/Boss/boss.tscn")

func _ready():
	var boss = boss_scene.instantiate()

	boss.level = 1
	boss.position = Vector2(500, 500)

	add_child(boss)
