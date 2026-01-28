extends Node2D


@onready var mask_generator = %MaskGenerator
@onready var notebook = %Notebook


var hight := 3
var lenght := 7

var mask_list :Array[Mask]


func _ready():
	notebook.visible = false

func generate_masks():
	var cant = hight * lenght
	for i in cant:
		var mask = mask_generator.create_mask()
		mask_list.append(mask)
	
	#elegir la mascara que vas a tener que encontrar
	GameManager.killer_mask = mask_list.pick_random()


func _on_button_pressed():
	notebook.visible = true


func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			notebook.visible = false
