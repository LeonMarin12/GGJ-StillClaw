extends Node

@onready var music = %Music
@onready var sound_effect = %SoundEffect
@onready var sound_ui = %SoundUI
@onready var dialogue = %Dialogue


@export_category('Musica')
@export var music_list :Dictionary[String, AudioStream]

@export_category('Ambeintes-SFX')
@export var sound_effect_list :Dictionary[String, AudioStream]

@export_category('Dialogue')
@export var dialogue_sound_list :Dictionary[String, AudioStream]

var sound_effect_looping :bool = false


func restart():
	# Detener toda la música y efectos de sonido
	music.stop()
	sound_effect.stop()
	sound_ui.stop()
	dialogue.stop()
	
	# Reiniciar flag de loop
	sound_effect_looping = false
	
	print("SoundManager reiniciado")


#region SoundEffect

func play_sound_effect(key :String, loop :bool = false):
	sound_effect_looping = loop
	sound_effect.stream = sound_effect_list[key]
	sound_effect.play()

func stop_sound_effect_loop():
	sound_effect_looping = false

func _on_sound_effect_finished():
	if sound_effect_looping:
		sound_effect.play()

#endregion

#region Dialogue

func play_dialogue_sound(letter: String, character: String = "default"):
	# Evitar reproducir sonido en espacios en blanco
	if letter.strip_edges() != "":
		# Usar el sonido del personaje si existe, sino usar "default"
		var sound_key = character if character in dialogue_sound_list else "default"
		if sound_key in dialogue_sound_list:
			dialogue.stream = dialogue_sound_list[sound_key]
			# Variar ligeramente el tono para que no sea monótono
			dialogue.pitch_scale = randf_range(0.9, 1.1)
			dialogue.play()

#endregion

#region Music

func play_music(key :String):
	music.stream = music_list[key]
	music.play()


func stop_music():
	music.stop()


func _on_music_finished():
	music.play()

#endregion
