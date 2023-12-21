extends TextureButton

signal seed_planted(seed_name)
var seed_name = "LunarTulip"
var tulip_value = 6
var is_planted = false
var growth_stage = 0
var max_growth_stage = 2
var growth_time = 60.0  # Seconds to grow to next stage
var tulip_sprout_offset = Vector2(0, -124)
var tulip_offset = Vector2(-40, -58)
var tulip_panel_offset = Vector2(-455, 938)
var tulip_visible = false
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
@onready var timer = $TulipTimer

func _ready():
	add_to_group("lunar_tulips")
	var day_night_timer = get_node("/root/Garden/DayNightCycle") # Adjust the path if it's different
	day_night_timer.connect("day_night_changed", _on_day_night_changed)
	day_night_timer.connect("weather_changed", _on_weather_changed)
	
func _on_day_night_changed(is_daytime):
	if is_daytime:
		is_day = true
		$TulipPanel/WaterButton.disabled = true
		$TulipPanel/FertilizerButton.disabled = true
		$TulipPanel/PruneButton.disabled = true
		if ($TulipTimer.time_left > 0):
			$TulipTimer.paused = true
			$TulipPanel/TulipLabel.text = "Doesn't grow in sunlight"
			print("Tulip timer paused")
			
	else:
		is_day = false
		$TulipPanel/WaterButton.disabled = false
		$TulipPanel/FertilizerButton.disabled = false
		if ($TulipTimer.time_left > 0):
			$TulipTimer.paused = false
			$TulipPanel/TulipLabel.text = "It's growing!"
			print("Tulip timer resumed")
		if growth_stage == 1:
			$TulipPanel/PruneButton.disabled = false
			
func _on_weather_changed(current_weather):
	if ($TulipTimer.time_left > 0):
		if not is_day:
			var remaining_time = $TulipTimer.time_left
			var modifier = weather_growth_modifiers[current_weather]
			$TulipTimer.wait_time = remaining_time * modifier
			$TulipTimer.start()
			print("Weather changed to ", current_weather, ", modifier applied: ", modifier, ". New wait time: ", $TulipTimer.wait_time)
			if current_weather == "rainy":
				$TulipPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $TulipTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$TulipTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$TulipTimer.start()
				else:
					$TulipTimer.wait_time = $TulipTimer.time_left - rain_bonus
					$TulipTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $TulipTimer.wait_time)
		else:
			print("Tulip timer paused. Remaining time: ", $TulipTimer.time_left)
	elif is_planted and growth_stage < max_growth_stage:
		var day_night_timer = get_node("/root/Garden/DayNightCycle") 
		var modifier = day_night_timer.weather_growth_modifiers[current_weather]
		$TulipTimer.wait_time = growth_time * modifier
		$TulipTimer.start()
		$TulipPanel/TulipLabel.text = "It's growing!"
		print("Defferred growth started with initial wait time: ", $TulipTimer.wait_time, "s, under ", current_weather, " weather.")
		if current_weather == "rainy":
				$TulipPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $TulipTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$TulipTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$TulipTimer.start()
				else:
					$TulipTimer.wait_time = $TulipTimer.time_left - rain_bonus
					$TulipTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $TulipTimer.wait_time)
					
func _start_growth(_seed_instance):
	self.texture_normal = null
	self.texture_hover = null
	is_planted = true
	var day_night_timer = get_node("/root/Garden/DayNightCycle") 
	var is_daytime = day_night_timer.is_daytime
	if not is_daytime:
		is_day =  false
		var current_weather = day_night_timer.current_weather
		var modifier = day_night_timer.weather_growth_modifiers[current_weather]
		$TulipTimer.wait_time = growth_time * modifier
		$TulipTimer.start()
		$TulipPanel/WaterButton.disabled = false
		$TulipPanel/PruneButton.disabled = true
		$TulipPanel/FertilizerButton.disabled = false
		$TulipPanel/TulipLabel.text = "It's growing!"
		print("Growth started with initial wait time: ", $TulipTimer.wait_time, "s, under ", current_weather, " weather.")
		if current_weather == "rainy":
				$TulipPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $TulipTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$TulipTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$TulipTimer.start()
				else:
					$TulipTimer.wait_time = $TulipTimer.time_left - rain_bonus
					$TulipTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $TulipTimer.wait_time)
	else:
		is_day =  true
		$TulipPanel/WaterButton.disabled = true
		$TulipPanel/PruneButton.disabled = true
		$TulipPanel/FertilizerButton.disabled = true
		$TulipPanel/TulipLabel.text = "Doesn't grow in sunlight"
		print("Tulip timer defferred")
	
func _on_tulip_timer_timeout():
	growth_stage += 1
	update_plant_appearance()
	print("Tulip timer timeout, growth stage: ", growth_stage)
	if growth_stage >= max_growth_stage:
		growth_stage = max_growth_stage
		print("Flower is fully grown")
		$TulipTimer.stop()
	else:
		var day_night_timer = get_node("/root/Garden/DayNightCycle")
		var current_weather = day_night_timer.current_weather
		var modifier = weather_growth_modifiers[current_weather]
		$TulipTimer.wait_time = growth_time * modifier
		$TulipTimer.start()  # Restart the timer with the new wait time
		print("The flower grew")
		print("Tulip timer restarted with new wait time: ", $TulipTimer.wait_time, ", for growth stage: ", growth_stage)
	
func update_plant_appearance():
	# Update the plant's sprite based on its growth stage
	if growth_stage == 1:
		$TulipPanel/PruneButton.disabled = false
		self.texture_normal = load("res://art/LunarTulipSprout.png")
		self.texture_hover = load("res://art/LunarTulipSproutHover.png")
		self.position = position + tulip_sprout_offset
		$TulipPanel.position = position + tulip_panel_offset
		print("Growth stage: ", growth_stage)
	elif growth_stage == 2:
		$TulipPanel.hide()
		self.texture_normal = load("res://art/LunarTulipFlower.png")
		self.texture_hover = load("res://art/LunarTulipFlowerHover.png")
		self.position = position + tulip_offset
		print("Growth stage: ", growth_stage)

func _on_lunar_tulip_pressed():
	if Global.selected_pot and seed_name == "LunarTulip" and not is_planted:
		Global.selected_pot.plant_seed(seed_name)
		emit_signal("seed_planted", seed_name)
		Global.remove_seed_from_inventory(seed_name)
	elif growth_stage >= max_growth_stage:
		var global_script = get_node("/root/Global")
		global_script.add_currency(tulip_value)
		self.queue_free()
		print("Sold ", seed_name)
	else:
		print("Tulip already planted")
		$TulipPanel.show()

func _on_water_button_pressed():
	var time_left_after_reduction = $TulipTimer.time_left - water_timer_deduct
	if ($TulipTimer.time_left > 0):
		$TulipPanel/WaterButton.disabled = true
		$WaterSound.play()
		$WaterParticles.emitting = true
		$WaterTimer.start()
		if time_left_after_reduction <= 0:
			$TulipTimer.wait_time = 0.01
			print("Flower watered - ", water_timer_deduct, "s = reached next stage")
			$TulipTimer.start()
		else:
			$TulipTimer.wait_time = time_left_after_reduction
			$TulipTimer.start()
			print("Flower watered - ", water_timer_deduct, "s = ", $TulipTimer.wait_time)	
	if growth_stage == 0:
		$WaterParticles.lifetime = 0.4
	if growth_stage == 1:
		$WaterParticles.lifetime = 0.6
	
func _on_water_timer_timeout():
	var day_night_timer = get_node("/root/Garden/DayNightCycle")
	var current_weather = day_night_timer.current_weather
	if not is_day and current_weather != "rainy":
		$TulipPanel/WaterButton.disabled = false

func _on_fertilizer_button_pressed():
	var time_left_after_reduction = $TulipTimer.time_left - fertilizer_timer_deduct
	if ($TulipTimer.time_left > 0):
		$TulipPanel/FertilizerButton.disabled = true
		$FertilizerSound.play()
		$FertilizerParticles.emitting = true
		if time_left_after_reduction <= 0:
			$TulipTimer.wait_time = 0.01
			print("Flower fertilized - ", fertilizer_timer_deduct, "s = reached next stage")
			$TulipTimer.start()
		else:
			$TulipTimer.wait_time = time_left_after_reduction
			$TulipTimer.start()
			print("Flower fertilized - ", fertilizer_timer_deduct, "s = ", $TulipTimer.wait_time)	
	if growth_stage == 0:
		$FertilizerParticles.lifetime = 0.4
	if growth_stage == 1:
		$FertilizerParticles.lifetime = 0.6
	
func _on_prune_button_pressed():
	var time_left_after_reduction = $TulipTimer.time_left - prune_timer_deduct
	if ($TulipTimer.time_left > 0):
		$TulipPanel/PruneButton.disabled = true
		$PruneSound.play()
		$PruneTimer.start()
		if time_left_after_reduction <= 0:
			$TulipTimer.wait_time = 0.01
			print("Flower pruned - ", prune_timer_deduct, "s = reached next stage")
			$TulipTimer.start()
		else:
			$TulipTimer.wait_time = time_left_after_reduction
			$TulipTimer.start()
		print("Flower pruned - ", prune_timer_deduct, "s = ", $TulipTimer.wait_time)	

func _on_prune_timer_timeout():
	if not is_day:
		$TulipPanel/PruneButton.disabled = false
		print("prune button enabled")

func _on_close_button_pressed():
	$TulipPanel.hide()
