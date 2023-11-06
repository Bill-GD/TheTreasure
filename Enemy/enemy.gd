class_name Enemy
extends CharacterBody2D

@onready var health_bar: ProgressBar = $HealthBar
@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Sprite
@onready var nav_agent: NavigationAgent2D = $EnemyNavigation

var death_effect_scene: PackedScene = load("res://OtherComponents/DeathEffect/death_effect.tscn")
var item_scene: PackedScene = load("res://OtherComponents/Item/item.tscn")

signal died

var target: Player

const BASE_SPEED: float = 100
const BASE_HP: int = 50
const BASE_DAMAGE: int = 4

var move_direction: Vector2
var level: int = 1
var total_hp: int = BASE_HP * level
var current_hp: int = total_hp * level
var damage: int = BASE_DAMAGE * level

var player_in_detect_range: bool = false
var player_close_range: bool = false
var has_seen_player: bool = false
var lost_player: bool = true


func _ready():
	target = get_parent().get_node("Player")
	health_bar.update_health(current_hp, total_hp)
	$PlayerDetection.connect('player_detection_changed', _on_player_detection_changed)
	velocity = Vector2.ZERO

func _process(_delta):
	if target:
		if not has_seen_player: move_direction = Vector2.ZERO
		else:
			if lost_player: # if has seen and lost -> pathfind
				move_direction = nav_agent.get_next_path_position() - position
			else:
				if $AttackCooldown.is_stopped(): # if seen, not lost -> attack
					$ShootSound.play()
					$SingleBulletAttack.shoot_bullet(self, target.global_position - global_position)
					$AttackCooldown.start()
				if player_close_range: # if seen, not lost and is close
					move_direction = (target.global_position - global_position).orthogonal()
				else: # if seen, not lost and not close
					move_direction = target.global_position - global_position
	else: move_direction = Vector2.ZERO
 
	# sprite.flip_h = velocity.x > 0

	velocity = move_direction.normalized() * BASE_SPEED
	move_and_slide()

	if current_hp <= 0:
		died.emit()

# func take_damage(amount: int):
# 	current_hp -= amount
# 	if current_hp <= 0:
# 		die()

func _on_died():
	if randf() > 0.5:
		var health_item: Item = item_scene.instantiate()
		health_item.position = global_position
		health_item.item_type = Item.ITEM_TYPE.HEALTH
		get_tree().root.add_child(health_item)

	var death_effect = death_effect_scene.instantiate()
	death_effect.position = global_position
	get_tree().root.add_child(death_effect)

	queue_free()

func _on_player_detection_changed():
	pass
