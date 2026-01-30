extends Node2D


@export var character_data: Dictionary[String, SpriteFrames] = {}
@onready var character_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var animation_player = %AnimationPlayer

var current_character: String = ""
var character_position_left := Vector2(360, 600)
var character_position_right := Vector2(1550, 600)
var pending_sprite: String = ""

func _ready():
	DialogueManager.got_dialogue.connect(_on_got_dialogue)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	SceneTransition.scene_changing.connect(_on_scene_changing)


func change_sprite(sprite_name :String):
	if current_character == '':
		# Si no hay personaje visible, guardar para aplicar después
		pending_sprite = sprite_name
		return
	elif character_sprite.sprite_frames.has_animation(sprite_name):
		character_sprite.play(sprite_name)
		pending_sprite = ""
	else:
		print('No se encontro la animacion de: ', sprite_name)


func play_animation(animation_name :String):
	if current_character == '': return
	elif animation_player.has_animation(animation_name):
		animation_player.play(animation_name)


func _show_character(character: String):
	if character == 'Detective':
		global_position = character_position_right
	else: global_position = character_position_left
	
	if character_data.has(character):
		var character_sprite_frames = character_data[character]
		character_sprite.sprite_frames = character_sprite_frames
		character_sprite.play("default")
		character_sprite.visible = true
		current_character = character
		
		# Si hay un sprite pendiente, aplicarlo
		if pending_sprite != "":
			if character_sprite.sprite_frames.has_animation(pending_sprite):
				character_sprite.play(pending_sprite)
			pending_sprite = ""
	else:
		push_warning("Personaje no encontrado: " + character, " (agregar a la lista)")
		character_sprite.visible = false
		current_character = ""


func _hide_character():
	character_sprite.visible = false
	current_character = ""
	pending_sprite = ""


func _on_got_dialogue(line: DialogueLine):
	var character_name = line.character
	if character_name == '':
		_hide_character()
	if character_name != current_character:
		_show_character(character_name)


func _on_dialogue_ended(_resource: DialogueResource):
	_hide_character()


func _on_scene_changing(_target):
	_hide_character()
