extends Node2D

var boss_scene: PackedScene = load("res://Enemy/Boss/boss.tscn")
var enemy_scene: PackedScene = load("res://Enemy/enemy.tscn")

@export var level: int
@export var next_level_packed: PackedScene
@export var level_map: TileMap
@export var player: Player

var total_enemy_count: int
var is_boss_dead: bool = false


func _ready():
	player = get_parent().get_node('Player')
	player.global_position = level_map.get_node('PlayerSpawnpoint').global_position
	setup_enemy()
	print('Finished setting up level: ', str(level))
	get_parent().update_current_level(self)
	get_parent().update_level_notification('Level %s' % level)
	# level_map.get_node('DarkArea').queue_free()
	# level_map.get_node('BossDoor').queue_free()

func _process(_delta):
	$Camera.global_position = player.global_position if player != null else Vector2.ZERO

func _on_enemy_died():
	total_enemy_count -= 1
	if total_enemy_count <= 0:
		get_parent().update_enemy_notification('All enemy defeated')
		print('all enemies defeated')
		if level_map.has_node('DarkArea'):
			level_map.get_node('DarkArea').queue_free()
		if level_map.has_node('BossDoor'):
			level_map.get_node('BossDoor').queue_free()
		if is_boss_dead:
			if level_map.has_node('TreasureDoor'):
				level_map.get_node('TreasureDoor').queue_free()
			if level_map.has_node('TreasureArea'):
				level_map.get_node('TreasureArea').connect('body_entered', _on_treasure_area_entered)
	else:
		get_parent().update_enemy_notification('Enemy remaining: %s' % total_enemy_count)
		print('enemy left: %s' % total_enemy_count)

func _on_boss_died() -> void:
	print('Level %s boss died' % level)
	get_parent().update_enemy_notification('The Boss is dead')
	is_boss_dead = true
	if level_map.has_node('ExitDoor'):
		level_map.get_node('ExitDoor').queue_free()
	if level_map.has_node('ExitArea'):
		level_map.get_node('ExitArea').connect('body_entered', _on_exit_area_entered)
	
	if total_enemy_count <= 0:
		if level_map.has_node('TreasureDoor'):
			level_map.get_node('TreasureDoor').queue_free()
		if level_map.has_node('TreasureArea'):
			level_map.get_node('TreasureArea').connect('body_entered', _on_treasure_area_entered)

func _on_exit_area_entered(body: Node2D) -> void:
	if body is Player:
		get_parent().change_level()

func _on_treasure_area_entered(body: Node2D) -> void:
	if body is Player:
		get_tree().root.get_node('Game/UI/GameOverMenu').show()

func setup_enemy(enemy_count: int = 10 + 5 * (level - 1)) -> void:
	var boss: BossEnemy = boss_scene.instantiate()
	boss.target = player
	boss.level = level
	boss.global_position = level_map.get_node('BossSpawnpoint').global_position
	boss.connect('died', _on_boss_died)
	add_child(boss)
	get_parent().connect_to_boss(boss)
	
	total_enemy_count = enemy_count
	for i in range(enemy_count):
		level_map.get_node('EnemyPath/EnemySpawn').progress_ratio = randf()
		spawn_enemy(level_map.get_node('EnemyPath/EnemySpawn').position)
	
	get_parent().update_enemy_notification('Enemy remaining: %s' % total_enemy_count)

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
