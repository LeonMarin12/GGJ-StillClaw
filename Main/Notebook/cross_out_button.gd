extends TextureButton


func _ready():
	self.modulate.a = 0.0


func _on_pressed():
	if self.modulate.a == 0.0:
		self.modulate.a = 1.0
	else: self.modulate.a = 0.0
