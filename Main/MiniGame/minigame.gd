extends Node2D

var cant_textures :int = 4 #dos de cada
var cant_joker :int = 2

const MAX_HBOX_CONTAINER :int = 5
const MAX_VBOX_CONTAINER :int = 5

@export var memotec_card_scene :PackedScene
@export var memotec_textures :Dictionary[String, Texture2D]
@export var joker_texture :Texture

@onready var memotec = %Memotec

func _ready():
	GameManager.reset_memotec.connect(_on_memotec_reset)


func set_memotec_cards():
	var cards_cant = (cant_textures * 2) + cant_joker
	var columns = ceil(sqrt(cards_cant))
	var rows = ceil(float(cards_cant) / columns)
	
	for i in rows:
		pass
		#crear un HBOXCONTAINER
		for j in columns:
			pass
			if cards_cant > 0:
				pass
				#crear un memotec y asignarlo al HBOXCONTAINER
			cards_cant -= 1
			
			

func _on_memotec_reset():
	pass
