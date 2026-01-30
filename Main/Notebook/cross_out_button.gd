extends Button

@onready var cross = %AnimatedSprite2D

var crossed := false

func _ready():
	cross.play("default")

func _on_pressed():
	
	
	if not crossed:
		cross.play("cross_out")
		crossed = true
	else: 
		cross.play_backwards("cross_out")
		crossed = false
