extends Node2D


@onready var mask_generator = %MaskGenerator
@onready var notebook = %Notebook
@onready var mask_grid_container = %MaskGridContainer
@onready var cross_grid_container = %CrossGridContainer

@export var cross_scene :PackedScene


var mask_cant :int = 32
var length := 8

var mask_list :Array[Mask]


func _ready():
	notebook.visible = false
	
	mask_grid_container.columns = length
	cross_grid_container.columns = length
	
	generate_masks()


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


func _on_button_pressed():
	notebook.visible = true


func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			notebook.visible = false
