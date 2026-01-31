extends CanvasLayer

func _ready():
	visible = false


func hide_menu():
	visible = false



func _on_back_pressed():
	hide_menu()
