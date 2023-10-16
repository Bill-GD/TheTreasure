extends CharacterBody2D

const BASE_SPEED: float = 150
const BASE_HP: int = 200
@export var player: CharacterBody2D

var is_attacking: bool = false
var is_aiming: bool = false
var pos_before_attack: Vector2

func _ready():
	$AttackCooldown.start()

func _physics_process(_delta):
	# movement
	# navigation or custom movement
	move_and_slide()

	# collision

	# aiming & rotation -> get player position

	# attacking
	if is_aiming:
		$Sprite2D.rotation = ((get_parent().get_node('Player') as CharacterBody2D).global_position - global_position).angle()
		$CollisionShape2D.rotation = $Sprite2D.rotation
		# look_at(player.global_position)
	if is_attacking and (get_last_slide_collision() or (global_position - pos_before_attack).length() > 500):
		velocity = Vector2.ZERO
		is_attacking = false
		$AttackCooldown.start()

	# sound ?

	pass

func prepare_attack():
	is_aiming = true
	$AttackTimer.start()

func _on_attack_timer_timeout():
	is_attacking = true
	is_aiming = false
	pos_before_attack = global_position
	await get_tree().create_timer(0.2).timeout
	velocity = Vector2.RIGHT.rotated($Sprite2D.rotation) * BASE_SPEED * 10


func _on_attack_cooldown_timeout():
	prepare_attack()
