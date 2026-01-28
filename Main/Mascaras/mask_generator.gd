extends Node2D

@export_category('Mask Scene')
@export var mask_scene :PackedScene

@export_category('Variations')
@export var forma_variations :Dictionary[String, Texture] 
@export var color_variations :Dictionary[String, Texture] 
@export var boca_variations :Dictionary[String, Texture]
@export var geometria_variations :Dictionary[String, Texture] 


func create_mask():
	var mask = mask_scene.instantiate()
	_apply_variation(mask, "forma", forma_variations, mask.sprite_forma)
	_apply_variation(mask, "color", color_variations, mask.sprite_color)
	_apply_variation(mask, "boca", boca_variations, mask.sprite_boca)
	_apply_variation(mask, "geometria", geometria_variations, mask.sprite_geometria)
	return mask


func _apply_variation(mask: Node2D, property_name: String, variations: Dictionary, sprite: Sprite2D) -> void:
	var random_key = variations.keys().pick_random()
	mask.property_name = random_key
	sprite.texture = variations[random_key]
