extends Node2D

@export var good_ending :Texture2D
@export var bad_ending :Texture2D

@onready var backgorund = $Backgorund
@onready var animation_player = $AnimationPlayer

@onready var main_menu_path :String = 'uid://b7glknau0bbwt'


func _ready():
	animation_player.play("dolly_out")
	if GameManager.guessed_correctly:
		backgorund.texture = good_ending
	else:
		backgorund.texture = bad_ending


func go_to_main_menu():
	get_tree().paused = false
	SceneTransition.change_scene(main_menu_path)


func _input(_event):
	if Input.is_action_just_pressed('pause'):
		go_to_main_menu()


func _on_backgorund_gui_input(event):
	await get_tree().create_timer(3).timeout
	if (event is InputEventMouseButton) and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			go_to_main_menu()
