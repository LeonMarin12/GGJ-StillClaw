extends Control

@onready var texture_button = %TextureButton
@onready var animation_player = %AnimationPlayer
@onready var joker_animation_player = %JokerAnimationPlayer
@onready var card_front = %card_front
@onready var memo_bien_sound = %MemoBien

var texture :Texture2D
var id_card :String
var is_flipped :bool = false
var reset_block_time :float = 1.5
var not_pair_block_time :float = 1.0

# Variable compartida entre todas las instancias de cartas
static var last_flip :String = ''
static var blocked :bool = false


func _ready():
	card_front.texture = texture
	GameManager.hide_cards_memotec.connect(_on_hide_card)
	GameManager.found_pair_memotec.connect(_on_found_pair_memotec)
	GameManager.reset_memotec.connect(_on_reset_memotec)


func _on_texture_button_pressed():
	if not is_flipped and not GameManager.finished_minigame:
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
	animation_player.play('flip_card')
	is_flipped = true
	# Manejar joker primero
	if flip_id_card == 'joker':
		block_mouse_input(reset_block_time)
		joker_animation_player.play('joker_laugh')
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
	if (id_card == hide_id_card or id_card == hide_last_flip) and is_flipped:
		is_flipped = false
		await get_tree().create_timer(not_pair_block_time).timeout
		animation_player.play_backwards('flip_card')
		


func _on_found_pair_memotec(found_id_card):
	block_mouse_input(0.1)
	await get_tree().create_timer(0.5).timeout #tiempo que tarda la animacion de flip
	if found_id_card == id_card:
		animation_player.queue("found_pair")
		memo_bien_sound.play()


func _on_reset_memotec():
	last_flip = ''
	
	await get_tree().create_timer(reset_block_time).timeout
	if is_flipped:
		animation_player.play_backwards('flip_card')
		is_flipped = false
