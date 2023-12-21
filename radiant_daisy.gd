extends TextureButton

signal seed_planted(seed_name)
var seed_name = "RadiantDaisy"
var daisy_value = 6
var is_planted = false
var growth_stage = 0
var max_growth_stage = 2
var growth_time = 60.0  # Seconds to grow to next stage
var daisy_sprout_offset = Vector2(-5, -112)
var daisy_offset = Vector2(-5, -95)
var daisy_panel_offset = Vector2(-430, 865)
var daisy_visible = false
var water_timer_deduct = 10.0
var prune_timer_deduct = 20.0
var fertilizer_timer_deduct = 30.0
var is_day
var weather_growth_modifiers = {
	"clear": 0.75, # Clear weather speeds up growth by 25%
	"par_cloudy": 1.0, 
	"cloudy": 1.25, # Cloudy weather slows down growth by 25%
	"rainy": 1.25, #Rainy weather slows down growth by 25%
	"snowy": 1.5, # Snowy weather slows down growth by 50%
}
@onready var timer = $DaisyTimer

func _ready():
	add_to_group("radiant_daisies")
	var day_night_timer = get_node("/root/Garden/DayNightCycle") # Adjust the path if it's different
	day_night_timer.connect("day_night_changed", _on_day_night_changed)
	day_night_timer.connect("weather_changed", _on_weather_changed)
	if not Global.is_step_completed("tend_seed"):
		$TendPlantTutorial.show()
		
func _process(_delta):
	if Global.is_step_completed("plot_unlocked") and not Global.is_step_completed("first_flower"):	
		$WaitForFlowerTutorial.show()
		
func _on_day_night_changed(is_daytime):
	if is_daytime:
		is_day = true
		$DaisyPanel/WaterButton.disabled = false
		$DaisyPanel/FertilizerButton.disabled = false
		if ($DaisyTimer.time_left > 0):
			$DaisyTimer.paused = false
			$DaisyPanel/DaisyLabel.text = "It's growing!"
			print("Daisy timer resumed")
		if growth_stage == 1:
			$DaisyPanel/PruneButton.disabled = false
	else:
		is_day = false
		$DaisyPanel/WaterButton.disabled = true
		$DaisyPanel/PruneButton.disabled = true
		$DaisyPanel/FertilizerButton.disabled = true
		if ($DaisyTimer.time_left > 0):
			$DaisyTimer.paused = true
			$DaisyPanel/DaisyLabel.text = "Doesn't grow in moonlight"
			print("Daisy timer paused")
	
func _on_weather_changed(current_weather):
	if ($DaisyTimer.time_left > 0):
		if is_day:
			var remaining_time = $DaisyTimer.time_left
			var modifier = weather_growth_modifiers[current_weather]
			$DaisyTimer.wait_time = remaining_time * modifier
			$DaisyTimer.start()
			print("Weather changed to ", current_weather, ", modifier applied: ", modifier, ". New wait time: ", $DaisyTimer.wait_time)
			if current_weather == "rainy":
				$DaisyPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $DaisyTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$DaisyTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$DaisyTimer.start()
				else:
					$DaisyTimer.wait_time = $DaisyTimer.time_left - rain_bonus
					$DaisyTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $DaisyTimer.wait_time)
		else:
			print("Daisy timer paused. Remaining time: ", $DaisyTimer.time_left)
	elif is_planted and growth_stage < max_growth_stage:
		var day_night_timer = get_node("/root/Garden/DayNightCycle") 
		var modifier = day_night_timer.weather_growth_modifiers[current_weather]
		$DaisyTimer.wait_time = growth_time * modifier
		$DaisyTimer.start()
		$DaisyPanel/DaisyLabel.text = "It's growing!"
		print("Defferred growth started with initial wait time: ", $DaisyTimer.wait_time, "s, under ", current_weather, " weather.")
		if current_weather == "rainy":
				$DaisyPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $DaisyTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$DaisyTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$DaisyTimer.start()
				else:
					$DaisyTimer.wait_time = $DaisyTimer.time_left - rain_bonus
					$DaisyTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $DaisyTimer.wait_time)
					
func _start_growth(_seed_instance):
	self.texture_normal = null
	self.texture_hover = null
	is_planted = true
	var day_night_timer = get_node("/root/Garden/DayNightCycle") 
	var is_daytime = day_night_timer.is_daytime
	if is_daytime:
		is_day =  true
		var current_weather = day_night_timer.current_weather
		var modifier = day_night_timer.weather_growth_modifiers[current_weather]
		$DaisyTimer.wait_time = growth_time * modifier
		$DaisyTimer.start()
		$DaisyPanel/WaterButton.disabled = false
		$DaisyPanel/PruneButton.disabled = true
		$DaisyPanel/FertilizerButton.disabled = false
		$DaisyPanel/DaisyLabel.text = "It's growing!"
		print("Growth started with initial wait time: ", $DaisyTimer.wait_time, "s, under ", current_weather, " weather.")
		if current_weather == "rainy":
				$DaisyPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $DaisyTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$DaisyTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$DaisyTimer.start()
				else:
					$DaisyTimer.wait_time = $DaisyTimer.time_left - rain_bonus
					$DaisyTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $DaisyTimer.wait_time)
	else:
		is_day =  false
		$DaisyPanel/WaterButton.disabled = true
		$DaisyPanel/PruneButton.disabled = true
		$DaisyPanel/FertilizerButton.disabled = true
		$DaisyPanel/DaisyLabel.text = "Doesn't grow in moonlight"
		print("Daisy timer defferred")
	
func _on_daisy_timer_timeout():
	growth_stage += 1
	update_plant_appearance()
	print("Daisy timer timeout, growth stage: ", growth_stage)
	if growth_stage >= max_growth_stage:
		growth_stage = max_growth_stage
		print("Flower is fully grown")
		$DaisyTimer.stop()
	else:
		var day_night_timer = get_node("/root/Garden/DayNightCycle")
		var current_weather = day_night_timer.current_weather
		var modifier = weather_growth_modifiers[current_weather]
		$DaisyTimer.wait_time = growth_time * modifier
		$DaisyTimer.start()  # Restart the timer with the new wait time
		print("The flower grew")
		print("Daisy timer restarted with new wait time: ", $DaisyTimer.wait_time, ", for growth stage: ", growth_stage)
	
func update_plant_appearance():
	# Update the plant's sprite based on its growth stage
	if growth_stage == 1:
		$DaisyPanel/PruneButton.disabled = false
		self.texture_normal = load("res://art/RadiantDaisySprout.png")
		self.texture_hover = load("res://art/RadiantDaisySproutHover.png")
		self.position = position + daisy_sprout_offset
		$DaisyPanel.position = position + daisy_panel_offset
		print("Growth stage: ", growth_stage)
	elif growth_stage == 2:
		$DaisyPanel.hide()
		self.texture_normal = load("res://art/RadiantDaisyFlower.png")
		self.texture_hover = load("res://art/RadiantDaisyFlowerHover.png")
		self.position = position + daisy_offset
		print("Growth stage: ", growth_stage)
		if not Global.is_step_completed("first_flower"):
			Global.mark_step_completed("first_flower")
			$WaitForFlowerTutorial.hide()
		if not Global.is_step_completed("sell_flower"):
			$SellFlowerTutorial.show()

func _on_radiant_daisy_pressed():
	if Global.selected_pot and seed_name == "RadiantDaisy" and not is_planted:
		Global.selected_pot.plant_seed(seed_name)
		emit_signal("seed_planted", seed_name)
		Global.remove_seed_from_inventory(seed_name)
	elif growth_stage >= max_growth_stage:
		var global_script = get_node("/root/Global")
		global_script.add_currency(daisy_value)
		self.queue_free()
		print("Sold ", seed_name)
		if not Global.is_step_completed("sell_flower"):
			Global.mark_step_completed("sell_flower")
			$SellFlowerTutorial.hide()
	else:
		print("Daisy already planted")
		$DaisyPanel.show()
		if not Global.is_step_completed("tend_seed"):
			Global.mark_step_completed("tend_seed")
			$TendPlantTutorial.hide()
			$TendPlantTutorial2.show()
		

func _on_water_button_pressed():
	if not Global.is_step_completed("water_seed"):
			Global.mark_step_completed("water_seed")
			$TendPlantTutorial2.hide()
			$TendPlantTutorial3.show()
	var time_left_after_reduction = $DaisyTimer.time_left - water_timer_deduct
	if ($DaisyTimer.time_left > 0):
		$DaisyPanel/WaterButton.disabled = true
		$WaterSound.play()
		$WaterParticles.emitting = true
		$WaterTimer.start()
		if time_left_after_reduction <= 0:
			$DaisyTimer.wait_time = 0.01
			print("Flower watered - ", water_timer_deduct, "s = reached next stage")
			$DaisyTimer.start()
		else:
			$DaisyTimer.wait_time = time_left_after_reduction
			$DaisyTimer.start()
			print("Flower watered - ", water_timer_deduct, "s = ", $DaisyTimer.wait_time)	
	if growth_stage == 0:
		$WaterParticles.lifetime = 0.4
	if growth_stage == 1:
		$WaterParticles.lifetime = 0.6
	
func _on_water_timer_timeout():
	var day_night_timer = get_node("/root/Garden/DayNightCycle")
	var current_weather = day_night_timer.current_weather
	if is_day and current_weather != "rainy":
		$DaisyPanel/WaterButton.disabled = false

func _on_fertilizer_button_pressed():
	if not Global.is_step_completed("fertilize_seed"):
			Global.mark_step_completed("fertilize_seed")
			$TendPlantTutorial3.hide()
	var time_left_after_reduction = $DaisyTimer.time_left - fertilizer_timer_deduct
	if ($DaisyTimer.time_left > 0):
		$DaisyPanel/FertilizerButton.disabled = true
		$FertilizerSound.play()
		$FertilizerParticles.emitting = true
		if time_left_after_reduction <= 0:
			$DaisyTimer.wait_time = 0.01
			print("Flower fertilized - ", fertilizer_timer_deduct, "s = reached next stage")
			$DaisyTimer.start()
		else:
			$DaisyTimer.wait_time = time_left_after_reduction
			$DaisyTimer.start()
			print("Flower fertilized - ", fertilizer_timer_deduct, "s = ", $DaisyTimer.wait_time)	
	if growth_stage == 0:
		$FertilizerParticles.lifetime = 0.4
	if growth_stage == 1:
		$FertilizerParticles.lifetime = 0.6
	
func _on_prune_button_pressed():
	var time_left_after_reduction = $DaisyTimer.time_left - prune_timer_deduct
	if ($DaisyTimer.time_left > 0):
		$DaisyPanel/PruneButton.disabled = true
		$PruneSound.play()
		$PruneTimer.start()
		if time_left_after_reduction <= 0:
			$DaisyTimer.wait_time = 0.01
			print("Flower pruned - ", prune_timer_deduct, "s = reached next stage")
			$DaisyTimer.start()
		else:
			$DaisyTimer.wait_time = time_left_after_reduction
			$DaisyTimer.start()
		print("Flower pruned - ", prune_timer_deduct, "s = ", $DaisyTimer.wait_time)	

func _on_prune_timer_timeout():
	if is_day:
		$DaisyPanel/PruneButton.disabled = false
		print("prune button enabled")

func _on_close_button_pressed():
	$DaisyPanel.hide()
