extends Node2D

@export_category('Mask Scene')
@export var mask_scene :PackedScene

@export_category('Variations')
@export var forma_variations :Dictionary[String, Texture] 
@export var color_variations :Dictionary[String, Color] 
@export var expresion_variations :Dictionary[String, Texture]
# Detalles organizados por forma: {'alas': {'patron1': texture1, ...}, 'corona': {...}}
@export var detalles_variations :Dictionary[String, Dictionary] 

var properties = ['forma', 'expresion']

var carac_espe_list :Dictionary = {
	'plumas' : ['alas', 'corona'],
	'calido' : ['rojo', 'amarillo'],
	'poker' : ['rombos', 'corazones'],
	'emocion' : ['sonrisa', 'triste']
}


func create_mask():
	var mask = mask_scene.instantiate()
	_apply_variations(mask)
	_apply_color(mask)
	_apply_detalles(mask)
	_apply_special_characteristics(mask)
	return mask


func _apply_variations(mask: Mask) -> void:
	for property_name in properties:
		var variations = get(property_name + "_variations")
		var sprite = mask.get("sprite_" + property_name)
		var random_key = variations.keys().pick_random()
		mask.set(property_name, random_key)
		sprite.texture = variations[random_key]


func _apply_color(mask: Mask) -> void:
	var random_color_key = color_variations.keys().pick_random()
	mask.color = random_color_key
	mask.detalles_color = color_variations[random_color_key]


func _apply_detalles(mask: Mask) -> void:
	# Los detalles dependen de la forma ya seleccionada
	if mask.forma in detalles_variations:
		var detalles_for_forma = detalles_variations[mask.forma]
		var random_detalle_key = detalles_for_forma.keys().pick_random()
		mask.detalles = random_detalle_key
		mask.sprite_detalles.texture = detalles_for_forma[random_detalle_key]


func _apply_special_characteristics(mask: Mask) -> void:
	var all_properties = ['forma', 'color', 'expresion', 'detalles']
	for caracteristica in carac_espe_list:
		for property_name in all_properties:
			if mask.get(property_name) in carac_espe_list[caracteristica]:
				mask.caracteristicas_especiales.append(caracteristica)
				break
