extends Node2D

@export var memotec_card_scene :PackedScene
@export var memotec_textures :Dictionary[String, Texture2D]
@export var joker_texture :Texture

@onready var v_box_container = %VBoxContainer
@onready var timer_label = %TimerLabel
@onready var timer = %Timer


var time_sec :int = 0###90
var cant_cards :int = 10
var cant_joker :int = 2
var texture_keys_list :Array[String] = ['ala', 'brillo', 'corazon', 'estrella', 'pluma']
var memotec_cards_list :Array
var pairs_found :int = 0


const MAX_HBOX_CONTAINER :int = 5
const MAX_VBOX_CONTAINER :int = 5


func _ready():
	GameManager.reset_memotec.connect(_on_memotec_reset)
	GameManager.found_pair_memotec.connect(_on_found_pair_memotec)
	GameManager.flip_card_memotec.connect(_on_flip_card_memotec)
	create_memotec_cards()
	set_memotec_cards()
	update_timer_label()


func create_memotec_cards():
	var cards_to_create = cant_cards
	
	for texture_key in texture_keys_list:
		if cards_to_create > 0:
			for i in 2: #se crean dos cartas iguales
				var new_card = memotec_card_scene.instantiate()
				new_card.texture = memotec_textures[texture_key]
				new_card.id_card = texture_key
				memotec_cards_list.append(new_card)
			cards_to_create -= 2
	
	for i in cant_joker:
		var new_joker = memotec_card_scene.instantiate()
		new_joker.texture = joker_texture
		new_joker.id_card = 'joker'
		memotec_cards_list.append(new_joker)


func set_memotec_cards():
	memotec_cards_list.shuffle()
	
	var cards_cant = memotec_cards_list.size()#cant_cards + cant_joker
	var columns = ceil(sqrt(cards_cant))
	var rows = ceil(float(cards_cant) / columns)
	
	var card_index = 0
	
	for i in rows:
		var hbox = HBoxContainer.new()
		v_box_container.add_child(hbox)
		for j in columns:
			if card_index < memotec_cards_list.size():
				hbox.add_child(memotec_cards_list[card_index])
				card_index += 1


func _on_flip_card_memotec(id_card):
	pass


func _on_found_pair_memotec(_id_card):
	pairs_found += 1
	if pairs_found >= float(cant_cards)/2:
		print('win')


func _on_memotec_reset():
	pairs_found = 0


func _on_timer_timeout():
	time_sec += 1 ###time_sec -= 1
	if time_sec > 0:
		update_timer_label()
	else:
		print('lost')



func update_timer_label():
	var time_left = time_sec
	var minutes = time_left / 60
	var seconds = time_left % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
	
