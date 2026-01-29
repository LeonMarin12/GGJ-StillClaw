extends Control

signal flip_card(is_joker)

@onready var texture_button = %TextureButton

var is_joker :bool = false

func _ready():
	flip_card.connect(_on_flip_card)

func _on_texture_button_pressed():
	texture_button.visible = false
	flip_card.emit(is_joker)

func _on_flip_card(_is_joker):
	if _is_joker:
		texture_button.visible = true
		GameManager.reset_memotec.emit()
