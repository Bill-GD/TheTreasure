extends ProgressBar

func update_health(current_health: int, max_health: int):
	max_value = max_health
	value = current_health
	var sb = StyleBoxFlat.new()
	var health_percent = float(current_health) / float(max_health)

	if health_percent < 0.25:
		sb.bg_color = Color("ff0000")
	elif health_percent < 0.5:
		sb.bg_color = Color("ff7400")
	elif health_percent < 0.75:
		sb.bg_color = Color("ffc100")
	else:
		sb.bg_color = Color("00ff00")
	add_theme_stylebox_override("fill", sb)
