extends Node2D

var plot_price = 0
var is_occupied = false
var is_unlocked = false
var pot_scene = preload("res://BasicPot.tscn")
var pot_offset = Vector2(-36, -36)
@onready var pot_sound = get_node("/root/Garden/PotSound")
@onready var unlock_sound = get_node("/root/Garden/UnlockSound")

func _process(_delta):
	if Global.is_step_completed("fertilize_seed") and not Global.is_step_completed("plot_unlocked"):
		$Plot2Button/UnlockPlotTutorial.show()

func _on_plot_2_button_pressed():
	if not is_occupied and is_unlocked:
		var pot_instance = pot_scene.instantiate()
		get_parent().add_child(pot_instance)
		pot_instance.position = position + pot_offset
		is_occupied = true
		$Plot2Button.hide()
		pot_sound.play()
		print("pot placed")
	else:
		$Plot2Unlock.show()
		$Plot2Button.hide()

func _on_plot_2_yes_pressed():
	if Global.is_step_completed("fertilize_seed"):
		unlock_plot()
		Global.mark_step_completed("plot_unlocked")

func unlock_plot():
	print("plot unlocked")
	is_unlocked = true
	unlock_sound.play()
	$Plot2Button.texture_normal = load("res://art/openlock.png")
	$Plot2Button.texture_hover = load("res://art/hoveropenlock.png")
	$Plot2Unlock.hide()
	$Plot2Button.show()
	$Plot2Button/UnlockPlotTutorial.hide()

func _on_plot_2_no_pressed():
	$Plot2Unlock.hide()
	$Plot2Button.show()

func _on_plot_2ok_pressed():
	$Plot2LowFunds.hide()
	$Plot2Button.show()
