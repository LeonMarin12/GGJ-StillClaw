extends Node2D


@onready var mask_generator = %MaskGenerator
@onready var notebook = %Notebook
@onready var display_notebook_button = %DisplayNotebookButton
@onready var mask_grid_container = %MaskGridContainer
@onready var cross_grid_container = %CrossGridContainer
@onready var clues_v_box_container = %CluesVBoxContainer


@export var cross_scene :PackedScene


var mask_cant :int = 32
var length := 8

var mask_list :Array[Mask]


func _ready():
	notebook.visible = false
	display_notebook_button.visible = false
	GameManager.notebook_picked.connect(_on_notebook_picked)
	
	mask_grid_container.columns = length
	cross_grid_container.columns = length
	
	generate_masks()


func switch_page():
	clues_v_box_container.visible = !clues_v_box_container.visible
	mask_grid_container.visible = !mask_grid_container.visible
	cross_grid_container.visible = !cross_grid_container.visible


func add_clue(clue_text):
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
	
	for _mask in mask_list:
		mask_grid_container.add_child(_mask)
		var cross = cross_scene.instantiate()
		cross_grid_container.add_child(cross)
	
	#elegir la mascara que vas a tener que encontrar
	GameManager.killer_mask = mask_list.pick_random()


func _create_unique_mask() -> Mask:
	var new_mask = mask_generator.create_mask()
	# Verificar si ya existe una máscara igual
	for existing_mask in mask_list:
		if new_mask.is_equal_to(existing_mask):
			# Descartar y generar una nueva
			new_mask.queue_free()
			return _create_unique_mask()
	return new_mask


func _on_notebook_picked():
	display_notebook_button.visible = true
	%AnimationPlayer.play("notebook_picked")


func _on_button_pressed():
	display_notebook_button.visible = false
	notebook.visible = true


func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			notebook.visible = false
			display_notebook_button.visible = true
