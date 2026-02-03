extends AnimatedSprite2D


func _on_button_mouse_entered():
	play("hover")


func _on_button_mouse_exited():
	play("default")


func _on_button_button_down():
	play("click")


func _on_button_button_up():
	play("default")
