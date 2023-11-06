extends Node2D

@onready var enemy_node: CharacterBody2D = get_parent()
@onready var line_of_sight: RayCast2D = $EnemyVision
var targeted_body: Player

signal player_detection_changed

@onready var enemy_node_detect_range: float = get_node('DetectRange/DetectRangeShape').shape.radius

func _ready() -> void:
	line_of_sight.global_position = enemy_node.global_position

func _process(_delta) -> void:
	if enemy_node.target and enemy_node.player_in_detect_range:
		var target_direction: Vector2 = (enemy_node.target.global_position - enemy_node.global_position)

		line_of_sight.global_position = enemy_node.global_position
		line_of_sight.target_position = target_direction.normalized() * min(enemy_node_detect_range, target_direction.length())

		if line_of_sight.get_collider() is Player:
			if not enemy_node.has_seen_player: enemy_node.has_seen_player = true
			enemy_node.move_direction = target_direction
			enemy_node.lost_player = false

		if not line_of_sight.get_collider() is Player and enemy_node.has_seen_player and not enemy_node.lost_player:
			enemy_node.nav_agent.update_target_position(enemy_node.target.global_position)
			enemy_node.lost_player = true

func _on_detect_range_body_entered(body: Node2D):
	if body != null and body is Player:
		enemy_node.player_in_detect_range = true
		if enemy_node is BossEnemy: player_detection_changed.emit()

func _on_detect_range_body_exited(body: Node2D):
	if body != null and body is Player:
		enemy_node.player_in_detect_range = false
		if enemy_node is BossEnemy: player_detection_changed.emit()

func _on_close_range_body_entered(body: Node2D):
	if body != null and body is Player:
		enemy_node.player_close_range = true
		if enemy_node is BossEnemy: player_detection_changed.emit()

func _on_close_range_body_exited(body: Node2D):
	if body != null and body is Player:
		enemy_node.player_close_range = false
		if enemy_node is BossEnemy: player_detection_changed.emit()
