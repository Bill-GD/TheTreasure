extends Node2D

@onready var parent: CharacterBody2D = get_parent()

signal player_detection_changed

func _on_detect_range_body_entered(body: Node2D):
	if parent.player_close_range: parent.player_detected = true
	else: parent.player_detected = body is Player
	player_detection_changed.emit()

func _on_detect_range_body_exited(body: Node2D):
	parent.player_detected = not (body is Player)
	player_detection_changed.emit()

func _on_close_range_body_entered(body: Node2D):
	parent.player_close_range = body is Player
	player_detection_changed.emit()

func _on_close_range_body_exited(body: Node2D):
	parent.player_close_range = not (body is Player)
	player_detection_changed.emit()

func _on_player_detection_changed():
	print('%s: Player detected: %s, Player close: %s' % ['Enemy' if parent is Enemy else 'Boss', parent.player_detected, parent.player_close_range])
