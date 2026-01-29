extends Control

@onready var texture_button = %TextureButton
@onready var texture_card = %TextureCard
@onready var animation_player = %AnimationPlayer

var texture :Texture2D
var id_card :String
var reset_block_time :float = 1.5
var not_pair_block_time :float = 1.0

# Variable compartida entre todas las instancias de cartas
static var last_flip :String = ''
static var blocked :bool = false


func _ready():
	texture_card.texture = texture
	GameManager.hide_cards_memotec.connect(_on_hide_card)
	GameManager.found_pair_memotec.connect(_on_found_pair_memotec)
	GameManager.reset_memotec.connect(_on_reset_memotec)


func _on_texture_button_pressed():
	texture_button.visible = false
	flip_card(id_card)


func _input(event):
	if blocked and event is InputEventMouse:
		get_viewport().set_input_as_handled() # "Consume" el evento para que nadie más lo reciba


func block_mouse_input(sec: float = 1.0):
	blocked = true
	await get_tree().create_timer(sec).timeout
	blocked = false


func flip_card(flip_id_card):
	GameManager.flip_card_memotec.emit(flip_id_card)
	# Manejar joker primero
	if flip_id_card == 'joker':
		block_mouse_input(reset_block_time)
		animation_player.play('joker_laugh')
		GameManager.reset_memotec.emit()
		return
	
	# Si es la primera carta volteada
	if last_flip == '':
		last_flip = flip_id_card
	
	# Si ya había una carta volteada
	elif last_flip == flip_id_card:
		# Se encontró un par
		GameManager.found_pair_memotec.emit(flip_id_card)
		last_flip = ''
	
	else:
		# No coinciden, voltearlas de nuevo
		block_mouse_input(not_pair_block_time)
		GameManager.hide_cards_memotec.emit(flip_id_card, last_flip)
		last_flip = ''


func _on_hide_card(hide_id_card, hide_last_flip):
	if id_card == hide_id_card or id_card == hide_last_flip:
		await get_tree().create_timer(not_pair_block_time).timeout
		texture_button.visible = true


func _on_found_pair_memotec(_found_id_card):
	block_mouse_input(0.1)


func _on_reset_memotec():
	last_flip = ''
	await get_tree().create_timer(reset_block_time).timeout
	texture_button.visible = true
