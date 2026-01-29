extends Control
class_name Mask


var sprite_forma: TextureRect:
	get:
		if not sprite_forma:
			sprite_forma = %SpriteForma
		return sprite_forma

var sprite_expresion: TextureRect:
	get:
		if not sprite_expresion:
			sprite_expresion = %SpriteExpresion
		return sprite_expresion

var sprite_detalles: TextureRect:
	get:
		if not sprite_detalles:
			sprite_detalles = %SpriteDetalles
		return sprite_detalles

var detalles_color :Color:
	set(value):
		detalles_color = value
		sprite_forma.modulate = value
		sprite_expresion.modulate = value
		sprite_detalles.modulate = value


var forma :String
var color :String
var expresion :String
var detalles :String

var caracteristicas_especiales :Array = []


func is_equal_to(other: Mask) -> bool:
	# Compara las propiedades principales de las máscaras
	return forma == other.forma and color == other.color and expresion == other.expresion and detalles == other.detalles
