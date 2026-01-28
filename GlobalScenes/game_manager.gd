extends Node

##tengo que hacer el sistema de dialogos
@export var recurso_dialogo: DialogueResource

#mascara que se va a tener que encontrar
var killer_mask :Mask

var booleano_de_prueba :bool = false
var _current_dialogue_label: DialogueLabel = null


func _ready():
	connect_dialogue_manager_signals()


func _input(event):
	if event.is_action_pressed('debug'):
		DialogueManager.show_dialogue_balloon(recurso_dialogo, 'start')


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
	pass

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
