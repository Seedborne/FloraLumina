extends TextureButton

signal seed_planted(seed_name)
var seed_name = "ZephyrZinnia"
var zinnia_value = 20
var is_planted = false
var growth_stage = 0
var max_growth_stage = 2
var growth_time = 120.0  # Seconds to grow to next stage
var zinnia_sprout_offset = Vector2(0, -110)
var zinnia_offset = Vector2(-10, -91)
var zinnia_panel_offset = Vector2(-460, 855)
var zinnia_visible = false
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
@onready var timer = $ZinniaTimer

func _ready():
	add_to_group("zephyr_zinnias")
	var day_night_timer = get_node("/root/Garden/DayNightCycle") # Adjust the path if it's different
	day_night_timer.connect("day_night_changed", _on_day_night_changed)
	day_night_timer.connect("weather_changed", _on_weather_changed)
	
func _on_day_night_changed(is_daytime):
	if is_daytime:
		is_day = true
		$ZinniaPanel/WaterButton.disabled = false
		$ZinniaPanel/FertilizerButton.disabled = false
		if ($ZinniaTimer.time_left > 0):
			$ZinniaTimer.paused = false
			$ZinniaPanel/ZinniaLabel.text = "It's growing!"
			print("Zinnia timer resumed")
		if growth_stage == 1:
			$ZinniaPanel/PruneButton.disabled = false
	else:
		is_day = false
		$ZinniaPanel/WaterButton.disabled = true
		$ZinniaPanel/PruneButton.disabled = true
		$ZinniaPanel/FertilizerButton.disabled = true
		if ($ZinniaTimer.time_left > 0):
			$ZinniaTimer.paused = true
			$ZinniaPanel/ZinniaLabel.text = "Doesn't grow in moonlight"
			print("Zinnia timer paused")
	
func _on_weather_changed(current_weather):
	if ($ZinniaTimer.time_left > 0):
		if is_day:
			var remaining_time = $ZinniaTimer.time_left
			var modifier = weather_growth_modifiers[current_weather]
			$ZinniaTimer.wait_time = remaining_time * modifier
			$ZinniaTimer.start()
			print("Weather changed to ", current_weather, ", modifier applied: ", modifier, ". New wait time: ", $ZinniaTimer.wait_time)
			if current_weather == "rainy":
				$ZinniaPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $ZinniaTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$ZinniaTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$ZinniaTimer.start()
				else:
					$ZinniaTimer.wait_time = $ZinniaTimer.time_left - rain_bonus
					$ZinniaTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $ZinniaTimer.wait_time)
		else:
			print("Zinnia timer paused. Remaining time: ", $ZinniaTimer.time_left)
	elif is_planted and growth_stage < max_growth_stage:
		var day_night_timer = get_node("/root/Garden/DayNightCycle") 
		var modifier = day_night_timer.weather_growth_modifiers[current_weather]
		$ZinniaTimer.wait_time = growth_time * modifier
		$ZinniaTimer.start()
		$ZinniaPanel/ZinniaLabel.text = "It's growing!"
		print("Defferred growth started with initial wait time: ", $ZinniaTimer.wait_time, "s, under ", current_weather, " weather.")
		if current_weather == "rainy":
				$ZinniaPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $ZinniaTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$ZinniaTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$ZinniaTimer.start()
				else:
					$ZinniaTimer.wait_time = $ZinniaTimer.time_left - rain_bonus
					$ZinniaTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $ZinniaTimer.wait_time)
					
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
		$ZinniaTimer.wait_time = growth_time * modifier
		$ZinniaTimer.start()
		$ZinniaPanel/WaterButton.disabled = false
		$ZinniaPanel/PruneButton.disabled = true
		$ZinniaPanel/FertilizerButton.disabled = false
		$ZinniaPanel/ZinniaLabel.text = "It's growing!"
		print("Growth started with initial wait time: ", $ZinniaTimer.wait_time, "s, under ", current_weather, " weather.")
		if current_weather == "rainy":
				$ZinniaPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $ZinniaTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$ZinniaTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$ZinniaTimer.start()
				else:
					$ZinniaTimer.wait_time = $ZinniaTimer.time_left - rain_bonus
					$ZinniaTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $ZinniaTimer.wait_time)
	else:
		is_day =  false
		$ZinniaPanel/WaterButton.disabled = true
		$ZinniaPanel/PruneButton.disabled = true
		$ZinniaPanel/FertilizerButton.disabled = true
		$ZinniaPanel/ZinniaLabel.text = "Doesn't grow in moonlight"
		print("Zinnia timer defferred")
	
func _on_zinnia_timer_timeout():
	growth_stage += 1
	update_plant_appearance()
	print("Zinnia timer timeout, growth stage: ", growth_stage)
	if growth_stage >= max_growth_stage:
		growth_stage = max_growth_stage
		print("Flower is fully grown")
		$ZinniaTimer.stop()
	else:
		var day_night_timer = get_node("/root/Garden/DayNightCycle")
		var current_weather = day_night_timer.current_weather
		var modifier = weather_growth_modifiers[current_weather]
		$ZinniaTimer.wait_time = growth_time * modifier
		$ZinniaTimer.start()  # Restart the timer with the new wait time
		print("The flower grew")
		print("Zinnia timer restarted with new wait time: ", $ZinniaTimer.wait_time, ", for growth stage: ", growth_stage)
	
func update_plant_appearance():
	# Update the plant's sprite based on its growth stage
	if growth_stage == 1:
		$ZinniaPanel/PruneButton.disabled = false
		self.texture_normal = load("res://art/ZephyrZinniaSprout.png")
		self.texture_hover = load("res://art/ZephyrZinniaSproutHover.png")
		self.position = position + zinnia_sprout_offset
		$ZinniaPanel.position = position + zinnia_panel_offset
		print("Growth stage: ", growth_stage)
	elif growth_stage == 2:
		$ZinniaPanel.hide()
		self.texture_normal = load("res://art/ZephyrZinniaFlower.png")
		self.texture_hover = load("res://art/ZephyrZinniaFlowerHover.png")
		self.position = position + zinnia_offset
		print("Growth stage: ", growth_stage)

func _on_zephyr_zinnia_pressed():
	if Global.selected_pot and seed_name == "ZephyrZinnia" and not is_planted:
		Global.selected_pot.plant_seed(seed_name)
		emit_signal("seed_planted", seed_name)
		Global.remove_seed_from_inventory(seed_name)
	elif growth_stage >= max_growth_stage:
		var global_script = get_node("/root/Global")
		global_script.add_currency(zinnia_value)
		self.queue_free()
		print("Sold ", seed_name)
	else:
		print("Zinnia already planted")
		$ZinniaPanel.show()

func _on_water_button_pressed():
	var time_left_after_reduction = $ZinniaTimer.time_left - water_timer_deduct
	if ($ZinniaTimer.time_left > 0):
		$ZinniaPanel/WaterButton.disabled = true
		$WaterSound.play()
		$WaterParticles.emitting = true
		$WaterTimer.start()
		if time_left_after_reduction <= 0:
			$ZinniaTimer.wait_time = 0.01
			print("Flower watered - ", water_timer_deduct, "s = reached next stage")
			$ZinniaTimer.start()
		else:
			$ZinniaTimer.wait_time = time_left_after_reduction
			$ZinniaTimer.start()
			print("Flower watered - ", water_timer_deduct, "s = ", $ZinniaTimer.wait_time)	
	if growth_stage == 0:
		$WaterParticles.lifetime = 0.4
	if growth_stage == 1:
		$WaterParticles.lifetime = 0.6
	
func _on_water_timer_timeout():
	var day_night_timer = get_node("/root/Garden/DayNightCycle")
	var current_weather = day_night_timer.current_weather
	if is_day and current_weather != "rainy":
		$ZinniaPanel/WaterButton.disabled = false

func _on_fertilizer_button_pressed():
	var time_left_after_reduction = $ZinniaTimer.time_left - fertilizer_timer_deduct
	if ($ZinniaTimer.time_left > 0):
		$ZinniaPanel/FertilizerButton.disabled = true
		$FertilizerSound.play()
		$FertilizerParticles.emitting = true
		if time_left_after_reduction <= 0:
			$ZinniaTimer.wait_time = 0.01
			print("Flower fertilized - ", fertilizer_timer_deduct, "s = reached next stage")
			$ZinniaTimer.start()
		else:
			$ZinniaTimer.wait_time = time_left_after_reduction
			$ZinniaTimer.start()
			print("Flower fertilized - ", fertilizer_timer_deduct, "s = ", $ZinniaTimer.wait_time)	
	if growth_stage == 0:
		$FertilizerParticles.lifetime = 0.4
	if growth_stage == 1:
		$FertilizerParticles.lifetime = 0.6
	
func _on_prune_button_pressed():
	var time_left_after_reduction = $ZinniaTimer.time_left - prune_timer_deduct
	if ($ZinniaTimer.time_left > 0):
		$ZinniaPanel/PruneButton.disabled = true
		$PruneSound.play()
		$PruneTimer.start()
		if time_left_after_reduction <= 0:
			$ZinniaTimer.wait_time = 0.01
			print("Flower pruned - ", prune_timer_deduct, "s = reached next stage")
			$ZinniaTimer.start()
		else:
			$ZinniaTimer.wait_time = time_left_after_reduction
			$ZinniaTimer.start()
		print("Flower pruned - ", prune_timer_deduct, "s = ", $ZinniaTimer.wait_time)	

func _on_prune_timer_timeout():
	if is_day:
		$ZinniaPanel/PruneButton.disabled = false
		print("prune button enabled")

func _on_close_button_pressed():
	$ZinniaPanel.hide()
