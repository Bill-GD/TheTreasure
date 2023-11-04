extends NavigationAgent2D

@onready var parent: CharacterBody2D = get_parent()
@onready var raycast: RayCast2D = $RayCast

func _process(_delta) -> void:
	pass
	# if parent.target:
	# 	var parent_detect_range: float = parent.get_node('PlayerDetection/DetectRange/DetectRangeShape').shape.radius
	# 	var target_direction: Vector2 = (parent.target.global_position - parent.global_position)

	# 	raycast.global_position = parent.global_position
	# 	raycast.target_position = target_direction.normalized() * min(parent_detect_range, target_direction.length())

		# if :
		# parent.player_close_range = raycast.get_collider() is Player
		# parent.player_detected = raycast.get_collider() is Player
		# else: parent.finding_player = false

func update_target_position(new_position: Vector2):
	target_position = new_position
