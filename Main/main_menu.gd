extends Control

@onready var game_path :String = 'uid://cdombc6vbttw'
@onready var options_menu = %OptionsMenu


func _ready():
	GameManager.restart()
	CharacterManager.restart()
	SoundManager.restart()
	
	options_menu.visible = false
	SoundManager.play_music('oficina_inicio')


func _on_start_button_pressed():
	SceneTransition.change_scene(game_path)


func _on_exit_button_pressed():
	get_tree().quit()


func _on_options_button_pressed():
	options_menu.visible = true
