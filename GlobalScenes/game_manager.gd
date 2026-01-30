extends Node

#señales para el memotec
signal reset_memotec
signal flip_card_memotec(id_card)
signal found_pair_memotec(id_card)
signal hide_cards_memotec(id_card, last_flip)

#señales de escenas
signal notebook_picked

#sistema de dialogos
@export var dialogue_scene_1: DialogueResource
@export var dialogue_scene_2: DialogueResource
@export var dialogue_scene_3: DialogueResource

@onready var scene_1_path :String = 'uid://cdombc6vbttw'
@onready var scene_2_path :String = 'uid://h048cndi5ieo'
@onready var scene_3_path :String = 'uid://cea0djo3bxlql'

@export var minigame_path :String = 'uid://bhrtamre6cf4l'

#mascara que se va a tener que encontrar
var killer_mask :Mask

#variables para el sonido de dialogo
var _current_dialogue_label: DialogueLabel = null
var _current_character: String = ""

#region Clues

# Variable para controlar si es la primera vez en el interrogatorio
var is_first_interrogation: bool = true

# Diccionarios de pistas organizadas por categoría
var color_clues :Dictionary[String, String] = {
	"rojo": "era color rojizo",
	"azul": "era color azulado",
	"verde": "era color verde",
	"amarillo": "era color amarillento"
}

var forma_clues :Dictionary[String, String] = {
	"luna": "tenía forma de luna",
	"estrella": "tenía forma de estrella",
	"alas": "tenía alas a los lados",
	"corona": "tenía una corona de plumas"
}

var detalles_clues :Dictionary[String, String] = {
	"corazon": "tenía detalles con forma de corazones",
	"estrellas": "tenía detalles con forma de estrellas",
	"gotas": "tenía detalles con forma de gotas",
	"rombos": "tenía detalles con forma de rombos"
}

var expresion_clues :Dictionary[String, String] = {
	"felicidad": "mostraba una expresión de felicidad",
	"tristeza": "mostraba una expresión de tristeza",
	"neutral": "mostraba una expresión neutral",
	"sin_boca": "no tenía boca"
}

var especial_clues :Dictionary[String, String] = {
	'plumas': 'tenia plumas',
	'calido': 'era un color calido',
	'poker': 'tenia detalles de poker',
	'emocion': 'mostraba una emocion'
}

var all_clues :Dictionary = {
	'color' : color_clues, 
	'forma' : forma_clues, 
	'detalles' : detalles_clues,
	'expresion' : expresion_clues, 
	'especial' : especial_clues
}

# Array para almacenar la pista actual [dificultad, caracteristica, variedad]
var actual_difficulty :int = 1
var actual_clue :Array = []

# Variables temporales para construir la pista antes de confirmarla
var temp_difficulty :int = 1
var temp_characteristic :String = ""
var temp_variety :String = ""

# Funciones para construir la pista temporal
func set_clue_difficulty(difficulty: int):
	temp_difficulty = difficulty

func set_clue_characteristic(characteristic: String):
	temp_characteristic = characteristic

func set_clue_variety(variety: String):
	temp_variety = variety
	# Cuando se establece la variedad, se confirma la pista completa
	confirm_clue()

func confirm_clue():
	actual_difficulty = temp_difficulty
	actual_clue = [temp_characteristic, temp_variety]
	print("Pista confirmada: ", actual_clue)
	### Aquí puedes procesar la pista y verificar contra killer_mask

func get_clue_text() -> String:
	if temp_characteristic == "" or temp_variety == "":
		return "Pista incompleta"
	
	# Buscar en el diccionario correspondiente
	if temp_characteristic in all_clues:
		var clue_dict = all_clues[temp_characteristic]
		if temp_variety in clue_dict:
			return clue_dict[temp_variety]
	
	return "Pista no encontrada"


func start_minigame():
	print("Iniciando minijuego con pista: ", actual_clue)
	SceneTransition.change_scene(minigame_path)
	# Aquí se puede iniciar el minijuego o cambiar de escena
	# Por ejemplo: change_scene(scene_minigame_path)

#endregion


func _ready():
	SceneTransition.scene_changing.connect(_on_scene_changing)
	connect_dialogue_manager_signals()


func _input(event):
	if event.is_action_pressed('debug'):
		DialogueManager.show_dialogue_balloon(dialogue_scene_3, 'start')


func change_scene(target):
	SceneTransition.change_scene(target)


func _on_scene_changing(target):
	if target == scene_1_path:
		DialogueManager.show_dialogue_balloon(dialogue_scene_1, 'start')
	elif target == scene_2_path:
		DialogueManager.show_dialogue_balloon(dialogue_scene_2, 'start')
	elif target == scene_3_path:
		DialogueManager.show_dialogue_balloon(dialogue_scene_3, 'start')


func pick_notebook():
	notebook_picked.emit()


#region DialogueManager Events

func connect_dialogue_manager_signals():
	# dialogue_started: Se emite cuando se crea un balloon de diálogo y el diálogo comienza
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	
	# passed_title: Se emite cuando se encuentra un título durante el recorrido del diálogo
	DialogueManager.passed_title.connect(_on_passed_title)
	
	# got_dialogue: Se emite cuando se encuentra una línea de diálogo
	DialogueManager.got_dialogue.connect(_on_got_dialogue)
	
	# mutated: Se emite cuando se encuentra una mutación (cambio de variables en el diálogo)
	DialogueManager.mutated.connect(_on_mutated)
	
	# dialogue_ended: Se emite cuando un diálogo ha llegado al final
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _on_dialogue_started(resource: DialogueResource):
	#print("Diálogo iniciado: ", resource.resource_path)
	pass


func _on_passed_title(title: String):
	#print("Título pasado: ", title)
	pass

func _on_got_dialogue(line: DialogueLine):
	print("Línea de diálogo: ", line.text)
	print('Perosonaje: ', line.character)
	# Guardar el personaje actual
	_current_character = line.character if line.character else "default"
	# Conectar las señales del DialogueLabel cuando recibimos una nueva línea de diálogo
	# Esto garantiza que las conectamos ANTES de que el label empiece a escribir
	var balloon = get_tree().get_first_node_in_group("dialogue_balloon")
	if balloon:
		var dialogue_label = balloon.get_node_or_null("%DialogueLabel")
		if dialogue_label and dialogue_label != _current_dialogue_label:
			_current_dialogue_label = dialogue_label
			connect_to_dialogue_label(dialogue_label)


func _on_mutated(mutation: Dictionary):
	#print("Mutación: ", mutation)
	pass

func _on_dialogue_ended(resource: DialogueResource):
	#print("Diálogo finalizado: ", resource.resource_path)
	pass

#endregion


#region DialogueLabel Events


func connect_to_dialogue_label(label: DialogueLabel):
	# Verificar y conectar solo si no están ya conectadas
	# spoke: Se emite por cada letra que se escribe
	if not label.spoke.is_connected(_on_label_spoke):
		label.spoke.connect(_on_label_spoke)
	
	# skipped_typing: Se emite cuando el jugador salta la escritura del diálogo
	if not label.skipped_typing.is_connected(_on_label_skipped_typing):
		label.skipped_typing.connect(_on_label_skipped_typing)
	
	# started_typing: Se emite cuando comienza a escribirse el texto
	if not label.started_typing.is_connected(_on_label_started_typing):
		label.started_typing.connect(_on_label_started_typing)
	
	# finished_typing: Se emite cuando termina de escribirse el texto
	if not label.finished_typing.is_connected(_on_label_finished_typing):
		label.finished_typing.connect(_on_label_finished_typing)


func disconnect_from_dialogue_label(label: DialogueLabel):
	# Desconectar todas las señales del DialogueLabel
	if label.spoke.is_connected(_on_label_spoke):
		label.spoke.disconnect(_on_label_spoke)
	
	if label.skipped_typing.is_connected(_on_label_skipped_typing):
		label.skipped_typing.disconnect(_on_label_skipped_typing)
	
	if label.started_typing.is_connected(_on_label_started_typing):
		label.started_typing.disconnect(_on_label_started_typing)
	
	if label.finished_typing.is_connected(_on_label_finished_typing):
		label.finished_typing.disconnect(_on_label_finished_typing)


func _on_label_spoke(letter: String, letter_index: int, speed: float):
	#print("Letra hablada: ", letter, " [índice: ", letter_index, ", velocidad: ", speed, "]")
	SoundManager.play_dialogue_sound(letter, _current_character)

func _on_label_skipped_typing():
	#print("Escritura saltada")
	pass

func _on_label_started_typing():
	#print("Comenzó a escribirse el texto")
	pass

func _on_label_finished_typing():
	#print("Terminó de escribirse el texto")
	pass

#endregion
