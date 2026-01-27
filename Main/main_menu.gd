extends Control

@onready var game_path :String = 'uid://cdombc6vbttw'


func _on_start_button_pressed():
	get_tree().change_scene_to_file(game_path)


func _on_exit_button_pressed():
	get_tree().quit()
