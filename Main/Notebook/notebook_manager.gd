extends Node2D


@onready var mask_generator = %MaskGenerator
@onready var notebook = %Notebook
@onready var display_notebook_button = %DisplayNotebookButton
@onready var change_page_button = %ChangePageButton
@onready var mask_grid_container = %MaskGridContainer
@onready var cross_grid_container = %CrossGridContainer
@onready var clues_v_box_container = %CluesVBoxContainer
@onready var mask_margin_container = %MaskMarginContainer
@onready var cross_margin_container = %CrossMarginContainer
@onready var clues_margin_container = %CluesMarginContainer



@export var cross_scene :PackedScene


var mask_cant :int = 24
var length := 6
var mask_list :Array[Mask]
var choose_killer = false
var chosen_killer_mask: Mask = null


func _ready():
	if not GameManager.have_notebook:
		print('a')
		display_notebook_button.visible = false
	notebook.visible = false
	change_page_button.visible = false
	clues_margin_container.visible = false
	GameManager.notebook_picked.connect(_on_notebook_picked)
	GameManager.killer_chosen.connect(_on_killer_chosen)
	GameManager.add_clue.connect(_on_add_clue)
	
	mask_grid_container.columns = length
	cross_grid_container.columns = length
	
	# Comprobar si hay máscaras guardadas
	if GameManager.has_saved_masks():
		load_saved_masks_and_crosses()
	else:
		generate_masks()


func switch_page():
	clues_v_box_container.visible = !clues_v_box_container.visible
	mask_grid_container.visible = !mask_grid_container.visible
	cross_grid_container.visible = !cross_grid_container.visible


func _on_add_clue(clue_text):
	var clue = Label.new()
	clue.add_theme_font_size_override("font_size", 30)
	clue.add_theme_constant_override("line_spacing", -5)
	clue.text = clue_text
	clue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	clue.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clues_v_box_container.add_child(clue)


func generate_masks():
	for i in mask_cant:
		var mask = _create_unique_mask()
		mask_list.append(mask)
	
	for i in range(mask_list.size()):
		var _mask = mask_list[i]
		mask_grid_container.add_child(_mask)
		var cross = cross_scene.instantiate()
		cross_grid_container.add_child(cross)
		
		# Conectar la señal del botón cruz con su índice
		if cross.has_signal("pressed"):
			cross.pressed.connect(_on_cross_pressed.bind(i))
	
	# Elegir la mascara que vas a tener que encontrar
	var killer = mask_list.pick_random()
	GameManager.killer_mask = killer
	print("Killer mask generado: ", killer.forma, " ", killer.color, " ", killer.expresion, " ", killer.detalles)
	
	# Guardar las máscaras y el estado inicial de las cruces en GameManager
	var initial_cross_states :Array[bool] = []
	for i in range(mask_list.size()):
		initial_cross_states.append(false)
	GameManager.save_masks_and_crosses(mask_list, initial_cross_states)
	# Asegurar que killer_mask se guarde inmediatamente
	GameManager.save_killer_mask(killer)


func display_notebook():
	display_notebook_button.visible = false
	if !choose_killer:
		change_page_button.visible = true
		notebook.visible = true


func _create_unique_mask() -> Mask:
	var new_mask = mask_generator.create_mask()
	# Verificar si ya existe una máscara igual
	for existing_mask in mask_list:
		if new_mask.is_equal_to(existing_mask):
			# Descartar y generar una nueva
			new_mask.queue_free()
			return _create_unique_mask()
	return new_mask


func load_saved_masks_and_crosses():
	# Cargar los datos de las máscaras guardadas y recrearlas
	var mask_data_list = GameManager.get_saved_mask_data()
	var cross_states = GameManager.get_saved_cross_states()
	var killer_mask_data = GameManager.get_saved_killer_mask_data()
	
	for i in range(mask_data_list.size()):
		# Recrear la máscara desde los datos guardados
		var mask = mask_generator.create_mask_from_data(mask_data_list[i])
		mask_list.append(mask)
		mask_grid_container.add_child(mask)
		
		# Si esta máscara coincide con killer_mask, asignarla a GameManager.killer_mask
		if not killer_mask_data.is_empty() and _mask_matches_data(mask, killer_mask_data):
			GameManager.killer_mask = mask
			print("Killer mask restaurado: ", mask.forma, " ", mask.color, " ", mask.expresion, " ", mask.detalles)
		
		var cross = cross_scene.instantiate()
		cross_grid_container.add_child(cross)
		
		# Restaurar el estado de la cruz
		if i < cross_states.size() and cross_states[i]:
			cross.crossed = true
			cross.cross.play("cross_out")
		
		# Conectar la señal del botón cruz con su índice
		if cross.has_signal("pressed"):
			cross.pressed.connect(_on_cross_pressed.bind(i))
	
	# Cargar las pistas guardadas
	var saved_clues = GameManager.get_saved_clues()
	for clue_text in saved_clues:
		var clue = Label.new()
		clue.add_theme_font_size_override("font_size", 30)
		clue.add_theme_constant_override("line_spacing", -5)
		clue.text = clue_text
		clue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		clue.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		clues_v_box_container.add_child(clue)


func _mask_matches_data(mask: Mask, mask_data: Dictionary) -> bool:
	return (mask.forma == mask_data.get("forma", "") and
			mask.color == mask_data.get("color", "") and
			mask.expresion == mask_data.get("expresion", "") and
			mask.detalles == mask_data.get("detalles", ""))


func _on_notebook_picked():
	display_notebook_button.visible = true
	%AnimationPlayer.play("notebook_picked")


func _on_killer_chosen():
	display_notebook()
	choose_killer = true


func _on_cross_pressed(index: int):
	# Si choose_killer es verdadero, guardar la máscara elegida y cerrar la libreta
	if choose_killer:
		# Guardar la máscara elegida por el jugador
		if index >= 0 and index < mask_list.size():
			chosen_killer_mask = mask_list[index]
			GameManager.killer_mask_guess = chosen_killer_mask
			
			# Verificar si el jugador acertó
			var is_correct = GameManager.check_killer_guess(chosen_killer_mask)
			print("Jugador eligió: ", chosen_killer_mask.forma, " ", chosen_killer_mask.color, " ", chosen_killer_mask.expresion, " ", chosen_killer_mask.detalles)
			print("¿Es correcto?: ", is_correct)
			
			# Cerrar la libreta
			notebook.visible = false
			display_notebook_button.visible = true
			
			#asesiono elegido
			choose_killer = false
		return
	
	# Comportamiento normal cuando no se está eligiendo al asesino
	# Guardar el estado actualizado de las cruces
	save_cross_states()


func _on_button_pressed():
	display_notebook()


func _on_color_rect_gui_input(event):
	if choose_killer:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			notebook.visible = false
			change_page_button.visible = false
			display_notebook_button.visible = true


func _on_change_page_button_pressed():
	mask_margin_container.visible = ! mask_margin_container.visible
	cross_margin_container.visible = !cross_margin_container.visible
	
	clues_margin_container.visible = !clues_margin_container.visible


func save_cross_states():
	# Guardar el estado actual de todas las cruces
	var cross_states :Array[bool] = []
	for i in range(cross_grid_container.get_child_count()):
		var cross = cross_grid_container.get_child(i)
		if cross.has_method("get") or "crossed" in cross:
			cross_states.append(cross.crossed)
		else:
			cross_states.append(false)
	GameManager.save_masks_and_crosses(mask_list, cross_states)
