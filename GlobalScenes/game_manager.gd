extends Node

#señales para el memotec
signal reset_memotec
signal flip_card_memotec(id_card)
signal found_pair_memotec(id_card)
signal hide_cards_memotec(id_card, last_flip)

#señales de escenas
signal notebook_picked
signal killer_chosen

#señales para notebook
signal add_clue(clue_text)

#sistema de dialogos
@export var dialogue_scene_1: DialogueResource
@export var dialogue_scene_2: DialogueResource
@export var dialogue_scene_3: DialogueResource

@onready var scene_1_path :String = 'uid://cdombc6vbttw'
@onready var scene_2_path :String = 'uid://h048cndi5ieo'
@onready var scene_3_path :String = 'uid://cea0djo3bxlql'

@onready var minigame_path :String = 'uid://bhrtamre6cf4l'

@onready var final_scene :String = 'uid://bhh7qwhnh5a33'

#mascara que se va a tener que encontrar
var killer_mask :Mask
#mascara que elegis
var killer_mask_guess :Mask
#resultado de si acertaste al asesino
var guessed_correctly :bool = false

#saber si tenes ya la libreta
var have_notebook = false

#guardar las mascaras generadas y el estado de las cruces
var saved_mask_data :Array[Dictionary] = []
var saved_cross_states :Array[bool] = []
var saved_clues :Array[String] = []
var saved_killer_mask_data :Dictionary = {}

#variable para saber si ganaste el minijuego
var winned_minigame :bool = false
var finished_minigame :bool = false

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
var actual_difficulty :String = 'facil'
var actual_clue :Array = []

# Variables temporales para construir la pista antes de confirmarla
var temp_difficulty :String = 'facil'
var temp_characteristic :String = ""
var temp_variety :String = ""

# Funciones para construir la pista temporal
func set_clue_difficulty(difficulty :String):
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
	
	# Debug: Verificar killer_mask
	if killer_mask:
		print("Killer mask: ", killer_mask.forma, " ", killer_mask.color, " ", killer_mask.expresion, " ", killer_mask.detalles)
		print("Características especiales: ", killer_mask.caracteristicas_especiales)
	else:
		print("WARNING: killer_mask es null!")
		print("Datos guardados: ", saved_killer_mask_data)
	
	print("Evaluando pista: ", temp_characteristic, " = ", temp_variety)
	
	# Buscar en el diccionario correspondiente
	if temp_characteristic in all_clues:
		var clue_dict = all_clues[temp_characteristic]
		if temp_variety in clue_dict:
			var clue_string = clue_dict[temp_variety]
			# Verificar si la pista coincide con el asesino
			var is_correct = is_clue_correct()
			print("¿Pista correcta?: ", is_correct)
			
			if not is_correct:
				clue_string = "no " + clue_string
			
			print("Texto final de pista: ", clue_string)
			
			#guardar la pista en GameManager
			save_clue(clue_string)
			#escribirla en el notebook
			add_clue.emit(clue_string)
			return clue_string
	
	return "Pista no encontrada"

func start_minigame():
	print("Iniciando minijuego con pista: ", actual_clue)
	SceneTransition.change_scene(minigame_path)
	# Aquí se puede iniciar el minijuego o cambiar de escena
	# Por ejemplo: change_scene(scene_minigame_path)


func is_clue_correct() -> bool:
	# Si killer_mask es null, intentar usar los datos guardados
	if not killer_mask:
		if saved_killer_mask_data.is_empty():
			return false
		
		# Comparar directamente con los datos guardados
		if temp_characteristic == "color":
			return saved_killer_mask_data.get("color", "") == temp_variety
		elif temp_characteristic == "forma":
			return saved_killer_mask_data.get("forma", "") == temp_variety
		elif temp_characteristic == "detalles":
			return saved_killer_mask_data.get("detalles", "") == temp_variety
		elif temp_characteristic == "expresion":
			return saved_killer_mask_data.get("expresion", "") == temp_variety
		elif temp_characteristic == "especial":
			var carac_especiales = saved_killer_mask_data.get("caracteristicas_especiales", [])
			return temp_variety in carac_especiales
		return false
	
	# Si killer_mask existe, comparar con el objeto
	if temp_characteristic == "color":
		return killer_mask.color == temp_variety
	elif temp_characteristic == "forma":
		return killer_mask.forma == temp_variety
	elif temp_characteristic == "detalles":
		return killer_mask.detalles == temp_variety
	elif temp_characteristic == "expresion":
		return killer_mask.expresion == temp_variety
	elif temp_characteristic == "especial":
		return temp_variety in killer_mask.caracteristicas_especiales
	
	return false



func give_first_clue() -> String:
	if not killer_mask:
		return "No hay asesino definido"
	
	# Array con las características disponibles
	var available_characteristics = ["color", "forma", "detalles", "expresion"]
	
	# Elegir una característica aleatoria
	var random_characteristic = available_characteristics.pick_random()
	
	# Establecer temp_characteristic
	temp_characteristic = random_characteristic
	
	# Obtener todas las opciones posibles para esa característica
	var all_options = []
	var killer_value = ""
	
	if random_characteristic == "color":
		all_options = color_clues.keys()
		killer_value = killer_mask.color
	elif random_characteristic == "forma":
		all_options = forma_clues.keys()
		killer_value = killer_mask.forma
	elif random_characteristic == "detalles":
		all_options = detalles_clues.keys()
		killer_value = killer_mask.detalles
	elif random_characteristic == "expresion":
		all_options = expresion_clues.keys()
		killer_value = killer_mask.expresion
	
	# Filtrar para obtener solo las opciones que NO coinciden con el asesino
	var wrong_options = []
	for option in all_options:
		if option != killer_value:
			wrong_options.append(option)
	
	# Elegir una opción incorrecta aleatoria
	if wrong_options.size() > 0:
		temp_variety = wrong_options.pick_random()
	else:
		# Fallback en caso de que no haya opciones incorrectas
		temp_variety = all_options.pick_random()
	
	# Retornar el texto de la pista (será incorrecta, con "no " al principio)
	return get_clue_text()


#endregion


func _ready():
	SceneTransition.scene_changing.connect(_on_scene_changing)
	connect_dialogue_manager_signals()


func _input(event):
	if event.is_action_pressed('debug'):
		DialogueManager.show_dialogue_balloon(dialogue_scene_3, 'start')
	elif event.is_action_pressed('debug_2'):
		GameManager.winned_minigame = true
		GameManager.finished_minigame = true
		DialogueManager.show_dialogue_balloon(dialogue_scene_3, 'start')
		change_scene(scene_3_path)

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
	have_notebook = true


func choose_killer():
	killer_chosen.emit()


func save_masks_and_crosses(mask_list: Array[Mask], cross_states: Array[bool]):
	# Guardar solo los datos de las máscaras, no los objetos
	saved_mask_data.clear()
	for mask in mask_list:
		var mask_info = {
			"forma": mask.forma,
			"color": mask.color,
			"expresion": mask.expresion,
			"detalles": mask.detalles,
			"caracteristicas_especiales": mask.caracteristicas_especiales.duplicate()
		}
		saved_mask_data.append(mask_info)
	saved_cross_states = cross_states.duplicate()
	
	# Guardar los datos de killer_mask si existe
	if killer_mask:
		saved_killer_mask_data = {
			"forma": killer_mask.forma,
			"color": killer_mask.color,
			"expresion": killer_mask.expresion,
			"detalles": killer_mask.detalles,
			"caracteristicas_especiales": killer_mask.caracteristicas_especiales.duplicate()
		}

func get_saved_mask_data() -> Array[Dictionary]:
	return saved_mask_data

func get_saved_cross_states() -> Array[bool]:
	return saved_cross_states

func has_saved_masks() -> bool:
	return saved_mask_data.size() > 0

func save_clue(clue_text: String):
	if clue_text not in saved_clues:
		saved_clues.append(clue_text)

func get_saved_clues() -> Array[String]:
	return saved_clues

func get_saved_killer_mask_data() -> Dictionary:
	return saved_killer_mask_data

func save_killer_mask(mask: Mask):
	if mask:
		saved_killer_mask_data = {
			"forma": mask.forma,
			"color": mask.color,
			"expresion": mask.expresion,
			"detalles": mask.detalles,
			"caracteristicas_especiales": mask.caracteristicas_especiales.duplicate()
		}
		print("Killer mask guardado: ", mask.forma, " ", mask.color)

func check_killer_guess(guessed_mask: Mask) -> bool:
	# Verificar contra el objeto killer_mask si existe
	if killer_mask:
		guessed_correctly = killer_mask.is_equal_to(guessed_mask)
		print("Verificación con killer_mask: ", guessed_correctly)
		return guessed_correctly
	
	# Si killer_mask es null, verificar contra los datos guardados
	if not saved_killer_mask_data.is_empty():
		guessed_correctly = (
			guessed_mask.forma == saved_killer_mask_data.get("forma", "") and
			guessed_mask.color == saved_killer_mask_data.get("color", "") and
			guessed_mask.expresion == saved_killer_mask_data.get("expresion", "") and
			guessed_mask.detalles == saved_killer_mask_data.get("detalles", "")
		)
		print("Verificación con datos guardados: ", guessed_correctly)
		return guessed_correctly
	
	print("ERROR: No hay killer_mask ni datos guardados para comparar")
	return false


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
	#print("Línea de diálogo: ", line.text)
	#print('Perosonaje: ', line.character)
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
