extends TextureButton

signal seed_planted(seed_name)
var seed_name = "SolarflareRose"
var rose_value = 36
var is_planted = false
var growth_stage = 0
var max_growth_stage = 2
var growth_time = 200.0
 # Seconds to grow to next stage
var rose_sprout_offset = Vector2(-20, -165)
var rose_offset = Vector2(-30, -56)
var rose_panel_offset = Vector2(-350, 1180)
var rose_visible = false
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
@onready var timer = $RoseTimer

func _ready():
	var day_night_timer = get_node("/root/Garden/DayNightCycle") # Adjust the path if it's different
	day_night_timer.connect("day_night_changed", _on_day_night_changed)
	day_night_timer.connect("weather_changed", _on_weather_changed)

func _on_day_night_changed(is_daytime):
	if is_daytime:
		is_day = true
		$RosePanel/WaterButton.disabled = false
		$RosePanel/FertilizerButton.disabled = false
		if ($RoseTimer.time_left > 0):
			$RoseTimer.paused = false
			$RosePanel/RoseLabel.text = "It's growing!"
			print("Rose timer resumed")
		if growth_stage == 1:
			$RosePanel/PruneButton.disabled = false
	else:
		is_day = false
		$RosePanel/WaterButton.disabled = true
		$RosePanel/FertilizerButton.disabled = true
		$RosePanel/PruneButton.disabled = true
		if ($RoseTimer.time_left > 0):
			$RoseTimer.paused = true
			$RosePanel/RoseLabel.text = "Doesn't grow in moonlight"
			print("Rose timer paused")
	
func _on_weather_changed(current_weather):
	if ($RoseTimer.time_left > 0):
		if is_day:
			var remaining_time = $RoseTimer.time_left
			var modifier = weather_growth_modifiers[current_weather]
			$RoseTimer.wait_time = remaining_time * modifier
			$RoseTimer.start()
			print("Weather changed to ", current_weather, " modifier applied: ", modifier, ". New wait time: ", $RoseTimer.wait_time)
			if current_weather == "rainy":
				$RosePanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $RoseTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$RoseTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$RoseTimer.start()
				else:
					$RoseTimer.wait_time = $RoseTimer.time_left - rain_bonus
					$RoseTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $RoseTimer.wait_time)
		else:
			print("Rose timer paused. Remaining time: ", $RoseTimer.time_left)
	elif is_planted and growth_stage < max_growth_stage:
		var day_night_timer = get_node("/root/Garden/DayNightCycle") 
		var modifier = day_night_timer.weather_growth_modifiers[current_weather]
		$RoseTimer.wait_time = growth_time * modifier
		$RoseTimer.start()
		$RosePanel/RoseLabel.text = "It's growing!"
		print("Defferred growth started with initial wait time: ", $RoseTimer.wait_time, "s, under ", current_weather, " weather.")
		if current_weather == "rainy":
				$RosePanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $RoseTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$RoseTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$RoseTimer.start()
				else:
					$RoseTimer.wait_time = $RoseTimer.time_left - rain_bonus
					$RoseTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $RoseTimer.wait_time)
					
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
		$RoseTimer.wait_time = growth_time * modifier
		$RoseTimer.start()
		$RosePanel/WaterButton.disabled = false
		$RosePanel/FertilizerButton.disabled = false
		$RosePanel/PruneButton.disabled = true
		$RosePanel/RoseLabel.text = "It's growing!"
		print("Growth started with initial wait time: ", $RoseTimer.wait_time, "s, under ", current_weather, " weather.")
		if current_weather == "rainy":
				$RosePanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $RoseTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$RoseTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$RoseTimer.start()
				else:
					$RoseTimer.wait_time = $RoseTimer.time_left - rain_bonus
					$RoseTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $RoseTimer.wait_time)
	else:
		is_day =  false
		$RosePanel/WaterButton.disabled = true
		$RosePanel/FertilizerButton.disabled = true
		$RosePanel/PruneButton.disabled = true
		$RosePanel/RoseLabel.text = "Doesn't grow in moonlight"
		print("Rose timer defferred")
	
func _on_rose_timer_timeout():
	growth_stage += 1
	update_plant_appearance()
	print("Rose timer timeout, growth stage: ", growth_stage)
	if growth_stage >= max_growth_stage:
		growth_stage = max_growth_stage
		print("Flower is fully grown")
		$RoseTimer.stop()
	else:
		var day_night_timer = get_node("/root/Garden/DayNightCycle")
		var current_weather = day_night_timer.current_weather
		var modifier = weather_growth_modifiers[current_weather]
		$RoseTimer.wait_time = growth_time * modifier
		$RoseTimer.start()  # Restart the timer with the new wait time
		print("The flower grew")
		print("Rose timer restarted with new wait time: ", $RoseTimer.wait_time, ", for growth stage: ", growth_stage)
	
func update_plant_appearance():
	# Update the plant's sprite based on its growth stage
	if growth_stage == 1:
		$RosePanel/PruneButton.disabled = false
		self.texture_normal = load("res://art/SolarflareRoseSprout.png")
		self.texture_hover = load("res://art/SolarflareRoseSproutHover.png")
		self.position = position + rose_sprout_offset
		$RosePanel.position = position + rose_panel_offset
		print("Growth stage: ", growth_stage)
	elif growth_stage == 2:
		$RosePanel.hide()
		self.texture_normal = load("res://art/SolarflareRoseFlower.png")
		self.texture_hover = load("res://art/SolarflareRoseFlowerHover.png")
		self.position = position + rose_offset
		print("Growth stage: ", growth_stage)

func _on_solarflare_rose_pressed():
	if Global.selected_pot and seed_name == "SolarflareRose" and not is_planted:
		Global.selected_pot.plant_seed(seed_name)
		emit_signal("seed_planted", seed_name)
		Global.remove_seed_from_inventory(seed_name)
	elif growth_stage >= max_growth_stage:
		var global_script = get_node("/root/Global")
		global_script.add_currency(rose_value)
		self.queue_free()
		print("Sold ", seed_name)
	else:
		print("Rose already planted")
		$RosePanel.show()

func _on_water_button_pressed():
	var time_left_after_reduction = $RoseTimer.time_left - water_timer_deduct
	if ($RoseTimer.time_left > 0):
		$RosePanel/WaterButton.disabled = true
		$WaterSound.play()
		$WaterParticles.emitting = true
		$WaterTimer.start()
		if time_left_after_reduction <= 0:
			$RoseTimer.wait_time = 0.01
			print("Flower watered - ", water_timer_deduct, "s = reached next stage")
			$RoseTimer.start()
		else:
			$RoseTimer.wait_time = time_left_after_reduction
			$RoseTimer.start()
			print("Flower watered - ", water_timer_deduct, "s = ", $RoseTimer.wait_time)	
	if growth_stage == 0:
		$WaterParticles.lifetime = 0.4
	if growth_stage == 1:
		$WaterParticles.lifetime = 0.6

func _on_water_timer_timeout():
	var day_night_timer = get_node("/root/Garden/DayNightCycle")
	var current_weather = day_night_timer.current_weather
	if is_day and current_weather != "rainy":
		$RosePanel/WaterButton.disabled = false

func _on_fertilizer_button_pressed():
	var time_left_after_reduction = $RoseTimer.time_left - fertilizer_timer_deduct
	if ($RoseTimer.time_left > 0):
		$RosePanel/FertilizerButton.disabled = true
		$FertilizerSound.play()
		$FertilizerParticles.emitting = true
		if time_left_after_reduction <= 0:
			$RoseTimer.wait_time = 0.01
			print("Flower watered - ", fertilizer_timer_deduct, "s = reached next stage")
			$RoseTimer.start()
		else:
			$RoseTimer.wait_time = time_left_after_reduction
			$RoseTimer.start()
			print("Flower fertilized - ", fertilizer_timer_deduct, "s = ", $RoseTimer.wait_time)	
	if growth_stage == 0:
		$FertilizerParticles.lifetime = 0.4
	if growth_stage == 1:
		$FertilizerParticles.lifetime = 0.6
	
func _on_prune_button_pressed():
	var time_left_after_reduction = $RoseTimer.time_left - prune_timer_deduct
	if ($RoseTimer.time_left > 0):
		$RosePanel/PruneButton.disabled = true
		$PruneSound.play()
		$PruneTimer.start()
		if time_left_after_reduction <= 0:
			$RoseTimer.wait_time = 0.01
			print("Flower pruned - ", prune_timer_deduct, "s = reached next stage")
			$RoseTimer.start()
		else:
			$RoseTimer.wait_time = time_left_after_reduction
			$RoseTimer.start()
		print("Flower pruned - ", prune_timer_deduct, "s = ", $RoseTimer.wait_time)	

func _on_prune_timer_timeout():
	if is_day:
		$RosePanel/PruneButton.disabled = false
		print("prune button enabled")

func _on_close_button_pressed():
	$RosePanel.hide()

