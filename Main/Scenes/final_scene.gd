extends Node2D

@export var good_ending :Texture2D
@export var bad_ending :Texture2D

@onready var backgorund = $Backgorund


func _ready():
	if GameManager.guessed_correctly:
		backgorund.texture = good_ending
	else:
		backgorund.texture = bad_ending
