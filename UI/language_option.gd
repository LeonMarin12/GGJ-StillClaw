extends OptionButton

var idioms :Dictionary = {
	'es' : 0,
	'en' : 1
}

func _ready():
	var idiom = TranslationServer.get_locale()
	if idiom.contains('en'):
		selected = idioms['en']
	elif idiom.contains('es'):
		selected = idioms['es']


func _on_item_selected(index):
	var new_idiom :String
	if index == 0: new_idiom = 'es'
	else: new_idiom = 'en'
	TranslationServer.set_locale(new_idiom)
