extends Node2D

@onready var parent: CharacterBody2D = get_parent()
var targeted_body: Player

signal player_detection_changed

func _on_detect_range_body_entered(body: Node2D):
	if not body is Player: return

	targeted_body = body
	parent.player_detected = true
	player_detection_changed.emit()

func _on_detect_range_body_exited(body: Node2D):
	if not body is Player: return

	targeted_body = body
	parent.player_detected = false
	player_detection_changed.emit()

func _on_close_range_body_entered(body: Node2D):
	if not body is Player: return

	targeted_body = body
	parent.player_close_range = true
	player_detection_changed.emit()

func _on_close_range_body_exited(body: Node2D):
	if not body is Player: return

	targeted_body = body
	parent.player_close_range = false
	player_detection_changed.emit()

func _on_player_detection_changed():
	# print('%s: Player detected: %s, Player close: %s' % ['Enemy' if parent is Enemy else 'Boss', parent.player_detected, parent.player_close_range])
	if not parent.has_seen_player: parent.has_seen_player = true
	parent.nav_agent.update_target_position(targeted_body.global_position)
	pass
