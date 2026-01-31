extends Control

@onready var main_menu_path :String = 'uid://b7glknau0bbwt'

func _ready():
	get_parent().visible = true
	set_visible(false)
	# Asegurar que el CanvasLayer padre esté por encima del balloon desde el inicio
	if get_parent() is CanvasLayer:
		get_parent().layer = 102


func _input(event):
	if event.is_action_pressed('pause'):
		handle_pause()


func handle_pause():
	if not SceneTransition.is_transitioning:
		if not get_tree().is_paused():
			set_visible(true)
			get_tree().paused = true
			revoke_balloon_priority()
		else:
			set_visible(false)
			get_tree().paused = false
			restore_balloon_priority()


func revoke_balloon_priority():
	var balloons = get_tree().get_nodes_in_group("dialogue_balloon")
	if balloons:
		for balloon in balloons:
			# Desactivar el balloon y quitarle el foco
			balloon.process_mode = Node.PROCESS_MODE_DISABLED


func restore_balloon_priority():
	var balloons = get_tree().get_nodes_in_group("dialogue_balloon")
	if balloons:
		for balloon in balloons:
			# Restaurar el proceso del balloon
			balloon.process_mode = Node.PROCESS_MODE_INHERIT


func _on_resume_button_pressed():
	handle_pause()


func _on_options_button_pressed():
	pass # Replace with function body.


func _on_main_menu_button_pressed():
	get_tree().paused = false
	SceneTransition.change_scene(main_menu_path)


func _exit_tree():
	if get_tree().is_paused():
		get_tree().paused = false
