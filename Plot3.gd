extends Node2D

var plot_price = 30
var money_needed = 33
var is_occupied = false
var is_unlocked = false
var pot_scene = preload("res://BasicPot.tscn")
var pot_offset = Vector2(-36, -36)
@onready var pot_sound = get_node("/root/Garden/PotSound")
@onready var unlock_sound = get_node("/root/Garden/UnlockSound")

func _on_plot_3_button_pressed():
	if not is_occupied and is_unlocked:
		var pot_instance = pot_scene.instantiate()
		get_parent().add_child(pot_instance)
		pot_instance.position = position + pot_offset
		is_occupied = true
		$Plot3Button.hide()
		pot_sound.play()
		print("pot placed")
	else:
		$Plot3Unlock.show()
		$Plot3Button.hide()

func _on_plot_3_yes_pressed():
	var global_script = get_node("/root/Global")
	var current_currency = global_script.get_currency()
	if current_currency >= money_needed:
		Global.spend_currency(plot_price)
		unlock_plot()
	else:
		$Plot3LowFunds.show()
		$Plot3Unlock.hide()

func unlock_plot():
	print("plot unlocked")
	is_unlocked = true
	unlock_sound.play()
	$Plot3Button.texture_normal = load("res://art/openlock.png")
	$Plot3Button.texture_hover = load("res://art/hoveropenlock.png")
	$Plot3Unlock.hide()
	$Plot3Button.show()

func _on_plot_3_no_pressed():
	$Plot3Unlock.hide()
	$Plot3Button.show()

func _on_plot_3ok_pressed():
	$Plot3LowFunds.hide()
	$Plot3Button.show()
	
