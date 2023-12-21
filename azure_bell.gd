extends TextureButton

signal seed_planted(seed_name)
var seed_name = "AzureBell"
var bell_value = 11
var is_planted = false
var growth_stage = 0
var max_growth_stage = 2
var growth_time = 90.0  # Seconds to grow to next stage
var bell_sprout_offset = Vector2(8, -150)
var bell_offset = Vector2(-30, -90)
var bell_panel_offset = Vector2(-550, 1090)
var bell_visible = false
var water_timer_deduct = 10.0
var prune_timer_deduct = 20.0
var fertilizer_timer_deduct = 30.0
var is_day
var weather_growth_modifiers = {
	"clear": 0.75, # Clear weather speeds up growth by 25%
	"par_cloudy": 1.0, # Clear weather speeds up growth by 25%
	"cloudy": 1.25, # Cloudy weather slows down growth by 25%
	"rainy": 1.25, #Rainy weather slows down growth by 25%
	"snowy": 1.5, # Snowy weather slows down growth by 50%
}
@onready var timer = $BellTimer

func _ready():
	add_to_group("azure_bells")
	var day_night_timer = get_node("/root/Garden/DayNightCycle") # Adjust the path if it's different
	day_night_timer.connect("day_night_changed", _on_day_night_changed)
	day_night_timer.connect("weather_changed", _on_weather_changed)

func _on_day_night_changed(is_daytime):
	if is_daytime:
		is_day = true
		$BellPanel/WaterButton.disabled = false
		$BellPanel/FertilizerButton.disabled = false
		if ($BellTimer.time_left > 0):
			$BellTimer.paused = false
			$BellPanel/BellLabel.text = "It's growing!"
			print("Bell timer resumed")
		if growth_stage == 1:
			$BellPanel/PruneButton.disabled = false
	else:
		is_day = false
		$BellPanel/WaterButton.disabled = true
		$BellPanel/FertilizerButton.disabled = true
		$BellPanel/PruneButton.disabled = true
		if ($BellTimer.time_left > 0):
			$BellTimer.paused = true
			$BellPanel/BellLabel.text = "Doesn't grow in moonlight"
			print("Bell timer paused")
	
func _on_weather_changed(current_weather):
	if ($BellTimer.time_left > 0):
		if is_day:
			var remaining_time = $BellTimer.time_left
			var modifier = weather_growth_modifiers[current_weather]
			$BellTimer.wait_time = remaining_time * modifier
			$BellTimer.start()
			print("Weather changed to ", current_weather, " modifier applied: ", modifier, ". New wait time: ", $BellTimer.wait_time)
			if current_weather == "rainy":
				$BellPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $BellTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$BellTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$BellTimer.start()
				else:
					$BellTimer.wait_time = $BellTimer.time_left - rain_bonus
					$BellTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $BellTimer.wait_time)
		else:
			print("Bell timer paused. Remaining time: ", $BellTimer.time_left)
	elif is_planted and growth_stage < max_growth_stage:
		var day_night_timer = get_node("/root/Garden/DayNightCycle") 
		var modifier = day_night_timer.weather_growth_modifiers[current_weather]
		$BellTimer.wait_time = growth_time * modifier
		$BellTimer.start()
		$BellPanel/BellLabel.text = "It's growing!"
		print("Defferred growth started with initial wait time: ", $BellTimer.wait_time, "s, under ", current_weather, " weather.")
		if current_weather == "rainy":
				$BellPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $BellTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$BellTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$BellTimer.start()
				else:
					$BellTimer.wait_time = $BellTimer.time_left - rain_bonus
					$BellTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $BellTimer.wait_time)
					
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
		$BellTimer.wait_time = growth_time * modifier
		$BellTimer.start()
		$BellPanel/WaterButton.disabled = false
		$BellPanel/FertilizerButton.disabled = false
		$BellPanel/PruneButton.disabled = true
		$BellPanel/BellLabel.text = "It's growing!"
		print("Growth started with initial wait time: ", $BellTimer.wait_time, "s, under ", current_weather, " weather.")
		if current_weather == "rainy":
				$BellPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $BellTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$BellTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$BellTimer.start()
				else:
					$BellTimer.wait_time = $BellTimer.time_left - rain_bonus
					$BellTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $BellTimer.wait_time)
	else:
		is_day =  false
		$BellPanel/WaterButton.disabled = true
		$BellPanel/FertilizerButton.disabled = true
		$BellPanel/PruneButton.disabled = true
		$BellPanel/BellLabel.text = "Doesn't grow in moonlight"
		print("Bell timer defferred")
	
func _on_bell_timer_timeout():
	growth_stage += 1
	update_plant_appearance()
	print("Bell timer timeout, growth stage: ", growth_stage)
	if growth_stage >= max_growth_stage:
		growth_stage = max_growth_stage
		print("Flower is fully grown")
		$BellTimer.stop()
	else:
		var day_night_timer = get_node("/root/Garden/DayNightCycle")
		var current_weather = day_night_timer.current_weather
		var modifier = weather_growth_modifiers[current_weather]
		$BellTimer.wait_time = growth_time * modifier
		$BellTimer.start()  # Restart the timer with the new wait time
		print("The flower grew")
		print("Bell timer restarted with new wait time: ", $BellTimer.wait_time, ", for growth stage: ", growth_stage)
	
func update_plant_appearance():
	# Update the plant's sprite based on its growth stage
	if growth_stage == 1:
		$BellPanel/PruneButton.disabled = false
		self.texture_normal = load("res://art/AzureBellSprout.png")
		self.texture_hover = load("res://art/AzureBellSproutHover.png")
		self.position = position + bell_sprout_offset
		$BellPanel.position = position + bell_panel_offset
		print("Growth stage: ", growth_stage)
	elif growth_stage == 2:
		$BellPanel.hide()
		self.texture_normal = load("res://art/AzureBellFlower.png")
		self.texture_hover = load("res://art/AzureBellFlowerHover.png")
		self.position = position + bell_offset
		print("Growth stage: ", growth_stage)

func _on_azure_bell_pressed():
	if Global.selected_pot and seed_name == "AzureBell" and not is_planted:
		Global.selected_pot.plant_seed(seed_name)
		emit_signal("seed_planted", seed_name)
		Global.remove_seed_from_inventory(seed_name)
	elif growth_stage >= max_growth_stage:
		var global_script = get_node("/root/Global")
		global_script.add_currency(bell_value)
		self.queue_free()
		print("Sold ", seed_name)
	else:
		print("Bell already planted")
		$BellPanel.show()

func _on_water_button_pressed():
	var time_left_after_reduction = $BellTimer.time_left - water_timer_deduct
	if ($BellTimer.time_left > 0):
		$BellPanel/WaterButton.disabled = true
		$WaterSound.play()
		$WaterParticles.emitting = true
		$WaterTimer.start()
		if time_left_after_reduction <= 0:
			$BellTimer.wait_time = 0.01
			print("Flower watered - ", water_timer_deduct, "s = reached next stage")
			$BellTimer.start()
		else:
			$BellTimer.wait_time = time_left_after_reduction
			$BellTimer.start()
			print("Flower watered - ", water_timer_deduct, "s = ", $BellTimer.wait_time)	
	if growth_stage == 0:
		$WaterParticles.lifetime = 0.4
	if growth_stage == 1:
		$WaterParticles.lifetime = 0.6

func _on_water_timer_timeout():
	var day_night_timer = get_node("/root/Garden/DayNightCycle")
	var current_weather = day_night_timer.current_weather
	if is_day and current_weather != "rainy":
		$BellPanel/WaterButton.disabled = false

func _on_fertilizer_button_pressed():
	var time_left_after_reduction = $BellTimer.time_left - fertilizer_timer_deduct
	if ($BellTimer.time_left > 0):
		$BellPanel/FertilizerButton.disabled = true
		$FertilizerSound.play()
		$FertilizerParticles.emitting = true
		if time_left_after_reduction <= 0:
			$BellTimer.wait_time = 0.01
			print("Flower watered - ", fertilizer_timer_deduct, "s = reached next stage")
			$BellTimer.start()
		else:
			$BellTimer.wait_time = time_left_after_reduction
			$BellTimer.start()
			print("Flower fertilized - ", fertilizer_timer_deduct, "s = ", $BellTimer.wait_time)	
	if growth_stage == 0:
		$FertilizerParticles.lifetime = 0.4
	if growth_stage == 1:
		$FertilizerParticles.lifetime = 0.6
	
func _on_prune_button_pressed():
	var time_left_after_reduction = $BellTimer.time_left - prune_timer_deduct
	if ($BellTimer.time_left > 0):
		$BellPanel/PruneButton.disabled = true
		$PruneSound.play()
		$PruneTimer.start()
		if time_left_after_reduction <= 0:
			$BellTimer.wait_time = 0.01
			print("Flower pruned - ", prune_timer_deduct, "s = reached next stage")
			$BellTimer.start()
		else:
			$BellTimer.wait_time = time_left_after_reduction
			$BellTimer.start()
		print("Flower pruned - ", prune_timer_deduct, "s = ", $BellTimer.wait_time)	

func _on_prune_timer_timeout():
	if is_day:
		$BellPanel/PruneButton.disabled = false
		print("prune button enabled")

func _on_close_button_pressed():
	$BellPanel.hide()
