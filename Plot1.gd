extends Node2D

var plot_price
var is_occupied = false
var is_unlocked = true
var pot_scene = preload("res://BasicPot.tscn")
var pot_offset = Vector2(-36, -36)
@onready var pot_sound = get_node("/root/Garden/PotSound")

func _on_plot_1_button_pressed():
	if not is_occupied and is_unlocked:
		var pot_instance = pot_scene.instantiate()
		get_parent().add_child(pot_instance)
		pot_instance.position = position + pot_offset
		is_occupied = true
		$Plot1Button.hide()
		pot_sound.play()
		print("pot placed")
	else:
		print("couldn't place pot")
