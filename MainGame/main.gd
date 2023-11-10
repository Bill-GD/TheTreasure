extends Node

var player_scene: PackedScene = preload('res://Player/player.tscn')
var level_1_scene: PackedScene = preload('res://Levels/Level_1/level_1.tscn')

@export var current_level: Node2D
var can_switch_level: bool = true


func _ready() -> void:
	$UI/MainMenu/VBoxContainer/CenterContainer/VBoxContainer/PlayButton.connect('pressed', _on_main_menu_play_button_pressed)
	$UI/MainMenu/VBoxContainer/CenterContainer/VBoxContainer/HelpButton.connect('pressed', _on_main_menu_help_button_pressed)
	$UI/MainMenu/VBoxContainer/CenterContainer/VBoxContainer/ExitButton.connect('pressed', _on_main_menu_exit_button_pressed)
	$UI/HelpMenu/BackButton.connect('pressed', _on_help_menu_back_button_pressed)
	$UI/InGameHud/PauseButton.connect('pressed', _on_pause_button_pressed)
	$UI/PauseMenu/VBoxContainer/CenterContainer/VBoxContainer/ContinueButton.connect('pressed', _on_pause_menu_continue_button_pressed)
	$UI/PauseMenu/VBoxContainer/CenterContainer/VBoxContainer/QuitButton.connect('pressed', _on_pause_menu_quit_button_pressed)
	$UI/GameOverMenu/QuitButton.connect('pressed', _on_pause_menu_quit_button_pressed)

	$UI/HelpMenu.hide()
	$UI/InGameHud.hide()
	$UI/PauseMenu.hide()
	$UI/GameOverMenu.hide()

func _on_main_menu_play_button_pressed() -> void:
	var player: Player = player_scene.instantiate()
	player.connect('died', _on_player_died)
	add_child(player)
	add_child(level_1_scene.instantiate())
	$UI/HelpMenu.hide()
	$UI/MainMenu.hide()
	$UI/InGameHud.show()

func _on_main_menu_help_button_pressed() -> void:
	$UI/HelpMenu.show()
	$UI/MainMenu.hide()

func _on_help_menu_back_button_pressed() -> void:
	$UI/MainMenu.show()
	$UI/HelpMenu.hide()

func _on_main_menu_exit_button_pressed() -> void:
	get_tree().quit()

func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	$UI/PauseMenu.show()

func _on_pause_menu_continue_button_pressed() -> void:
	$UI/PauseMenu.hide()
	get_tree().paused = false

func _on_pause_menu_quit_button_pressed() -> void:
	$UI/PauseMenu.hide()
	get_tree().paused = false
	current_level.queue_free()
	if has_node('Player'): $Player.queue_free()
	$UI/GameOverMenu.hide()
	$UI/GameOverMenu/TitleLabel.text = 'YOU WON'
	$UI/InGameHud.hide()
	$UI/PauseMenu.hide()
	$UI/MainMenu.show()

func _on_player_died() -> void:
	current_level.stop_all_enemies()
	# current_level.queue_free()
	$UI/GameOverMenu/TitleLabel.text = 'YOU DIED'
	$UI/GameOverMenu.show()
	$UI/InGameHud.hide()
	# $UI/MainMenu.show()

func connect_to_boss(current_level_boss_node: BossEnemy) -> void:
	if current_level_boss_node:
		current_level_boss_node.connect('died', _on_current_level_boss_died)
		
func _on_current_level_boss_died() -> void:
	$Player.level_up()
	if current_level.next_level_packed:
		can_switch_level = true
	else:
		$UI/GameOverMenu.show()

func change_level():
	if can_switch_level:
		var next_level = (current_level.next_level_packed as PackedScene).instantiate()
		current_level.queue_free()
		add_child(next_level)
		can_switch_level = false

func update_current_level(level_node: Node2D):
	current_level = level_node
	print('Current level: %s' % current_level)
