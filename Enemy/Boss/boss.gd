class_name BossEnemy
extends CharacterBody2D

@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Sprite
@onready var health_bar: ProgressBar = $HealthBar
@onready var nav_agent: NavigationAgent2D = $EnemyNavigation

signal died

@export var player: Player

const BASE_SPEED: float = 150
const BASE_HP: int = 200
const BASE_DAMAGE: int = 5

var tween: Tween

var level: int = 1
var damage: int = BASE_DAMAGE * level
var total_hp: int = BASE_HP * level
var current_hp: int = total_hp

var is_attacking: bool = false
var is_aiming: bool = false
var pos_before_dash: Vector2

var player_detected: bool = false
var player_close_range: bool = false
var has_seen_player: bool = false

enum ATTACKS {
	DASH,
	SHOOT_NORMAL,
	SHOOT_SPREAD,
	SPIN,
}
var current_attack: ATTACKS
var available_attacks = []


func _ready():
	health_bar.update_health(current_hp, total_hp)

	player = get_parent().get_node('Player') as Player
	$AttackCooldown.start()

	$Boss_PlayerDetection.connect('player_detection_changed', _on_player_detection_changed)
	velocity = Vector2.ZERO

func _physics_process(_delta):
	if player:
		if player_detected:
			# aiming & rotation -> get player position
			if is_aiming:
				sprite.rotation = (player.global_position - global_position).angle()
				collision.rotation = sprite.rotation

			# attacking
			if is_attacking:
				if current_attack == ATTACKS.DASH and (get_last_slide_collision() or (global_position - pos_before_dash).length() > 200):
					velocity = Vector2.ZERO
					is_attacking = false
					$AttackCooldown.start()
				if current_attack == ATTACKS.SPIN:
					velocity = Vector2.ZERO
					spin()
					attack()
			# sound ?
		# navigation if player not detected
		elif has_seen_player:
			var path_direction = (nav_agent.get_next_path_position() - position).normalized()
			velocity = path_direction * BASE_SPEED
			sprite.rotation = path_direction.angle()
		else: velocity = Vector2.ZERO
	else: velocity = Vector2.ZERO

	if current_hp <= 0:
		died.emit()

	# move_and_collide(velocity * delta)
	move_and_slide()

func prepare_attack():
	$AttackTimer.start()
	is_aiming = true

func _on_attack_timer_timeout():
	is_attacking = true
	is_aiming = false
	pos_before_dash = global_position
	await get_tree().create_timer(0.2).timeout

	if current_attack == ATTACKS.DASH:
		velocity = Vector2.RIGHT.rotated(sprite.rotation) * BASE_SPEED * 10
	if current_attack == ATTACKS.SHOOT_NORMAL or current_attack == ATTACKS.SHOOT_SPREAD:
		velocity = (player.global_position - global_position).normalized() * 30 * (level - 1)
		attack()
		is_attacking = false
		$AttackCooldown.start()

func _on_attack_cooldown_timeout():
	if len(available_attacks) <= 0: 
		$AttackCooldown.start()
		return
	current_attack = ATTACKS[available_attacks[randi() % len(available_attacks)]]
	prepare_attack()

func attack():
	var shoot_direction: Vector2 = (player.global_position - global_position).normalized()

	if current_attack == ATTACKS.SHOOT_SPREAD:
		$SingleBulletAttack.shoot_bullet(self, shoot_direction)
		$SingleBulletAttack.shoot_bullet(self, Vector2.RIGHT.rotated(shoot_direction.angle() + -PI/12).normalized())
		$SingleBulletAttack.shoot_bullet(self, Vector2.RIGHT.rotated(shoot_direction.angle() + PI/12).normalized())
	elif current_attack == ATTACKS.SPIN:
		$SingleBulletAttack.shoot_bullet(self, Vector2.RIGHT.rotated(sprite.rotation), global_position + Vector2.RIGHT.rotated(sprite.rotation) * collision.shape.radius, 100)
	else:
		$SingleBulletAttack.shoot_bullet(self, shoot_direction)

func spin():
	if tween and tween.is_running(): return

	tween = create_tween()
	tween.tween_property(sprite, "rotation", sprite.rotation + TAU * 2, 1)
	tween.connect('finished', _on_tween_finished)
	tween.play()

func _on_tween_finished():
	if tween: tween.kill()
	is_attacking = false
	$AfterSpinCooldown.start()

func _on_died():
	queue_free()

func _on_player_detection_changed():
	# attacks
	if not player_detected: available_attacks = []
	if player_detected and not player_close_range: available_attacks = ['DASH']
	if player_close_range: available_attacks = ['SHOOT_NORMAL', 'SHOOT_SPREAD', 'SPIN']

func _on_enemy_navigation_navigation_finished():
	velocity = Vector2.ZERO
	pass # Replace with function body.
