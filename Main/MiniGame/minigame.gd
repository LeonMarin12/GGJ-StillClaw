extends Node2D

@export var memotec_card_scene :PackedScene
@export var memotec_textures :Dictionary[String, Texture2D]
@export var joker_texture :Texture

@onready var v_box_container = %VBoxContainer
@onready var timer_label = %TimerLabel
@onready var timer = %Timer
@onready var testigo_sprite = %TestigoSprite
@onready var detective_strite = %DetectiveStrite


#{'dificultad' : [time, cant_cards, cant_joker]}
var difficulty_list :Dictionary = {
	'facil' : [60, 10, 2],
	'dificil' : [60, 12, 4]
}

var time_sec :int = 0###90
var cant_cards :int = 12
var cant_joker :int = 4
var texture_keys_list :Array[String] = ['ala', 'corazon', 'estrella', 'pluma', 'rombo', 'sol', 'gota', 'luna']
var memotec_cards_list :Array
var pairs_found :int = 0
var first_card_fliped = false

const MAX_HBOX_CONTAINER :int = 5
const MAX_VBOX_CONTAINER :int = 5


func _ready():
	set_difficulty(GameManager.actual_difficulty)
	GameManager.reset_memotec.connect(_on_memotec_reset)
	GameManager.found_pair_memotec.connect(_on_found_pair_memotec)
	GameManager.flip_card_memotec.connect(_on_flip_card_memotec)
	create_memotec_cards()
	set_memotec_cards()
	update_timer_label()
	
	GameManager.finished_minigame = false


func set_difficulty(difficulty):
	var dif_car = difficulty_list[difficulty]
	time_sec = dif_car[0]
	cant_cards = dif_car[1]
	cant_joker = dif_car[2]


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
	var total_cards_cant = memotec_cards_list.size()#cant_cards + cant_joker
	var columns = ceil(sqrt(total_cards_cant))
	var rows = ceil(float(total_cards_cant) / columns)
	var card_index = 0
	
	for i in rows:
		var hbox = HBoxContainer.new()
		v_box_container.add_child(hbox)
		for j in columns:
			if card_index < memotec_cards_list.size():
				hbox.add_child(memotec_cards_list[card_index])
				card_index += 1


func _on_flip_card_memotec(_id_card):
	testigo_sprite.play('default')
	detective_strite.play('pensando')
	if not first_card_fliped:
		timer.start()
		first_card_fliped = true


func _on_found_pair_memotec(_id_card):
	pairs_found += 1
	testigo_sprite.play('sorprendido')
	if pairs_found >= float(cant_cards)/2:
		GameManager.winned_minigame = true
		GameManager.finished_minigame = true
		go_to_scene_3()
		print('win')


func _on_memotec_reset():
	testigo_sprite.play('triste')
	detective_strite.play('enojado')
	pairs_found = 0


func _on_timer_timeout():
	if GameManager.finished_minigame: return
	time_sec += 1 ###time_sec -= 1
	if time_sec >= 0:
		update_timer_label()
	else:
		GameManager.winned_minigame = false
		GameManager.finished_minigame = true
		go_to_scene_3()
		print('lost')


func update_timer_label():
	var time_left = time_sec
	var minutes = time_left / 60
	var seconds = time_left % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]


func go_to_scene_3():
	await get_tree().create_timer(3).timeout
	GameManager.change_scene(GameManager.scene_3_path)
