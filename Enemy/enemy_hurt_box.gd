extends Area2D

var enemy_hover_stat_scene: PackedScene = preload("res://OtherComponents/EnemyHoverStat/enemy_hover_stat.tscn")

@onready var parent: CharacterBody2D = get_parent()
@onready var player: Player = parent.target
@onready var health_bar: HealthBar = get_parent().get_node('HealthBar')




func _on_body_entered(body:Node2D):
	if body != null:
		if body is Bullet and (body.shooter == null or body.shooter is Player):
			$SoundEffect.play()
			body.hit_entity.emit()
			parent.current_hp -= body.actual_damage
			health_bar.update_health(parent.current_hp, parent.total_hp)
			if get_parent().has_node('EnemyHoverStat'):
				get_parent().get_node('EnemyHoverStat').text = '%s: %s / %s' % ['Enemy' if parent is Enemy else 'Boss', parent.current_hp, parent.total_hp]

func _on_mouse_entered():
	var enemy_hover_stat: Label = enemy_hover_stat_scene.instantiate()
	enemy_hover_stat.text = '%s: %s / %s' % ['Enemy' if parent is Enemy else 'Boss', parent.current_hp, parent.total_hp]
	get_parent().add_child(enemy_hover_stat)
	print('%s: %s / %s' % ['Enemy' if parent is Enemy else 'Boss', parent.current_hp, parent.total_hp])

func _on_mouse_exited():
	for child in get_parent().get_children():
		if child is EnemyHoverStat:
			child.queue_free()