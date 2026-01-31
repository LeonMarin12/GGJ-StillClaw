extends Control

@onready var game_path :String = 'uid://cdombc6vbttw'


func _on_start_button_pressed():
	SceneTransition.change_scene(game_path)


func _on_exit_button_pressed():
	get_tree().quit()


func _on_options_button_pressed():
	pass # Replace with function body.
