extends Node2D

var boss_scene: PackedScene = load("res://Enemy/Boss/boss.tscn")
var enemy_scene: PackedScene = load("res://Enemy/enemy.tscn")

@export var level: int
@export var level_map: TileMap
var total_enemy_count: int
@export var player: Player


func _ready():
	player = get_parent().get_node('Player')
	player.global_position = level_map.get_node('PlayerSpawnpoint').global_position
	setup_enemy()

func _on_enemy_died():
	total_enemy_count -= 1
	print('enemy left: %s' % total_enemy_count)
	if total_enemy_count <= 0:
		print('all enemies defeated')
		if level_map.has_node('DarkArea'):
			level_map.get_node('DarkArea').queue_free()
		if level_map.has_node('BossDoor'):
			level_map.get_node('BossDoor').queue_free()

func setup_enemy(enemy_count: int = 10) -> void:
	total_enemy_count = enemy_count
	for i in range(enemy_count):
		level_map.get_node('EnemyPath/EnemySpawn').progress_ratio = randf()
		spawn_enemy(level_map.get_node('EnemyPath/EnemySpawn').position)
	
	var boss: BossEnemy = boss_scene.instantiate()
	boss.target = player
	boss.level = level
	boss.global_position = level_map.get_node('BossSpawnpoint').global_position
	add_child(boss)

func spawn_enemy(spawn_location: Vector2) -> void:
	var enemy: Enemy = enemy_scene.instantiate()
	enemy.connect('died', _on_enemy_died)
	enemy.level = level
	enemy.global_position = spawn_location
	add_child(enemy)

func stop_all_enemies() -> void:
	for child in get_children():
		if child is Enemy or child is BossEnemy:
			child.get_node('StateMachine').set_process(false)
			child.get_node('StateMachine').set_physics_process(false)
			child.set_process(false)
			child.set_physics_process(false)
