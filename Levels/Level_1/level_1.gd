extends Node2D

@export var boss_scene: PackedScene = load("res://Enemy/Boss/boss.tscn")
@export var enemy_scene: PackedScene = load("res://Enemy/enemy.tscn")

# var boss_count: int = 0
@onready var player: Player = get_node('Player')
var total_enemy_count: int

func _ready():
	# spawn_boss()
	$Boss.set_physics_process(false)
	setup_enemy()

func _on_boss_died():
	# boss_count += 1
	# player.level_up()
	$LevelCooldown.start()

func _on_level_cooldown_timeout():
	# spawn_boss()
	pass

func _on_enemy_died():
	total_enemy_count -= 1
	print('enemy left: %s' % total_enemy_count)
	if total_enemy_count <= 0:
		print('all enemies defeated')
		$Boss.set_physics_process(true)
		$Level1_Map/DarkArea.queue_free()
		$Level1_Map/BossDoor.queue_free()

func setup_enemy(enemy_count: int = 10) -> void:
	total_enemy_count = enemy_count
	for i in range(enemy_count):
		$Level1_Map/EnemyPath/EnemySpawn.progress_ratio = randf()
		spawn_enemy($Level1_Map/EnemyPath/EnemySpawn.position)

func spawn_enemy(spawn_location: Vector2) -> void:
	var enemy: Enemy = enemy_scene.instantiate()
	enemy.connect('died', _on_enemy_died)
	enemy.global_position = spawn_location
	add_child(enemy)
