extends CharacterBody2D

const BASE_SPEED: float = 150
const BASE_HP: int = 20
const BASE_ARMOR: int = 10
const SPRINT_SPEED: float = BASE_SPEED * 2

func _physics_process(_delta):
	# movement
	var direction = Input.get_vector('aswd_left', 'aswd_right', 'aswd_up', 'aswd_down')
	
	velocity = direction * (SPRINT_SPEED if Input.is_key_pressed(KEY_SHIFT) else BASE_SPEED)
	move_and_slide()

	# collision

	# aiming & rotation
	$Sprite.rotation = (get_global_mouse_position() - global_position).angle()
	$Collision.rotation = $Sprite.rotation

	# shooting

	# sound ?
