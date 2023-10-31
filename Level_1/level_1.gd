extends Node2D

@export var boss_scene: PackedScene = load("res://Enemy/Boss/boss.tscn")

var boss_count: int = 0
@onready var player: Player = get_node('Player')

func _ready():
	spawn_boss()

func spawn_boss():
	var boss = boss_scene.instantiate()

	boss.level = boss_count + 1
	boss.position = Vector2(500, 500)
	boss.connect('died', _on_boss_died)

	# add_child(boss)
	# print('Boss spawned at: %s' % get_node('Boss').position)

func _on_boss_died():
	boss_count += 1
	player.level_up()
	$LevelCooldown.start()

func _on_level_cooldown_timeout():
	spawn_boss()
