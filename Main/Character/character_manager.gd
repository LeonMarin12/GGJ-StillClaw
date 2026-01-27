extends Node2D


@export var character_data: Dictionary[String, SpriteFrames] = {}
@onready var character_sprite: AnimatedSprite2D = %AnimatedSprite2D

var current_character: String = ""
var character_position: Vector2


func _ready():
	DialogueManager.got_dialogue.connect(_on_got_dialogue)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func show_character(character: String):
	if character_data.has(character):
		print('SI HAY')
		var character_sprite_frames = character_data[character]
		character_sprite.sprite_frames = character_sprite_frames
		character_sprite.play("default")
		character_sprite.visible = true
		current_character = character
	else:
		push_warning("Personaje no encontrado: " + character, " (agregar a la lista)")
		character_sprite.visible = false
		current_character = ""


func hide_character():
	character_sprite.visible = false
	current_character = ""


func _on_got_dialogue(line: DialogueLine):
	var character_name = line.character
	if character_name != current_character:
		show_character(character_name)


func _on_dialogue_ended(_resource: DialogueResource):
	hide_character()
