extends Node2D

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var dialogue_label: DialogueLabel = $Balloon/DialogueLabel

func _ready() -> void:
	# Conectamos la señal spoke del label
	dialogue_label.spoke.connect(_on_dialogue_label_spoke)

func _on_dialogue_label_spoke(letter: String, _letter_index: int, _speed: float) -> void:
	# Evitamos que suene en espacios en blanco para que se sienta más natural
	if letter.strip_edges() != "":
		# Opcional: Variar ligeramente el tono para que no sea monótono
		audio_player.pitch_scale = randf_range(0.9, 1.1)
		audio_player.play()
