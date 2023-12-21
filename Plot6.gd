extends Node2D

var plot_price = 200
var money_needed = 203
var is_occupied = false
var is_unlocked = false
var pot_scene = preload("res://BasicPot.tscn")
var pot_offset = Vector2(-36, -36)
@onready var pot_sound = get_node("/root/Garden/PotSound")
@onready var unlock_sound = get_node("/root/Garden/UnlockSound")

func _on_plot_6_button_pressed():
	if not is_occupied and is_unlocked:
		var pot_instance = pot_scene.instantiate()
		get_parent().add_child(pot_instance)
		pot_instance.position = position + pot_offset
		is_occupied = true
		$Plot6Button.hide()
		pot_sound.play()
		print("pot placed")
	else:
		$Plot6Unlock.show()
		$Plot6Button.hide()

func _on_plot_6_yes_pressed():
	var global_script = get_node("/root/Global")
	var current_currency = global_script.get_currency()
	if current_currency >= money_needed:
		Global.spend_currency(plot_price)
		unlock_plot()
	else:
		$Plot6LowFunds.show()
		$Plot6Unlock.hide()

func unlock_plot():
	print("plot unlocked")
	is_unlocked = true
	unlock_sound.play()
	$Plot6Button.texture_normal = load("res://art/openlock.png")
	$Plot6Button.texture_hover = load("res://art/hoveropenlock.png")
	$Plot6Unlock.hide()
	$Plot6Button.show()

func _on_plot_6_no_pressed():
	$Plot6Unlock.hide()
	$Plot6Button.show()

func _on_plot_6ok_pressed():
	$Plot6LowFunds.hide()
	$Plot6Button.show()
	
