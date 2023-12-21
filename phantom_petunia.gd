extends TextureButton

signal seed_planted(seed_name)
var seed_name = "PhantomPetunia"
var petunia_value = 11
var is_planted = false
var growth_stage = 0
var max_growth_stage = 2
var growth_time = 90.0  # Seconds to grow to next stage
var petunia_sprout_offset = Vector2(10, -108)
var petunia_offset = Vector2(-25, -60)
var petunia_panel_offset = Vector2(-520, 842)
var petunia_visible = false
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
@onready var timer = $PetuniaTimer

func _ready():
	add_to_group("phantom_petunias")
	var day_night_timer = get_node("/root/Garden/DayNightCycle") # Adjust the path if it's different
	day_night_timer.connect("day_night_changed", _on_day_night_changed)
	day_night_timer.connect("weather_changed", _on_weather_changed)
	
func _on_day_night_changed(is_daytime):
	if is_daytime:
		is_day = true
		$PetuniaPanel/WaterButton.disabled = true
		$PetuniaPanel/FertilizerButton.disabled = true
		$PetuniaPanel/PruneButton.disabled = true
		if ($PetuniaTimer.time_left > 0):
			$PetuniaTimer.paused = true
			$PetuniaPanel/PetuniaLabel.text = "Doesn't grow in sunlight"
			print("Petunia timer paused")
	else:
		is_day = false
		$PetuniaPanel/WaterButton.disabled = false
		$PetuniaPanel/FertilizerButton.disabled = false
		if ($PetuniaTimer.time_left > 0):
			$PetuniaTimer.paused = false
			$PetuniaPanel/PetuniaLabel.text = "It's growing!"
			print("Petunia timer resumed")
		if growth_stage == 1:
			$PetuniaPanel/PruneButton.disabled = false
	
func _on_weather_changed(current_weather):
	if ($PetuniaTimer.time_left > 0):
		if not is_day:
			var remaining_time = $PetuniaTimer.time_left
			var modifier = weather_growth_modifiers[current_weather]
			$PetuniaTimer.wait_time = remaining_time * modifier
			$PetuniaTimer.start()
			print("Weather changed to ", current_weather, ", modifier applied: ", modifier, ". New wait time: ", $PetuniaTimer.wait_time)
			if current_weather == "rainy":
				$PetuniaPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $PetuniaTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$PetuniaTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$PetuniaTimer.start()
				else:
					$PetuniaTimer.wait_time = $PetuniaTimer.time_left - rain_bonus
					$PetuniaTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $PetuniaTimer.wait_time)
		else:
			print("Petunia timer paused. Remaining time: ", $PetuniaTimer.time_left)
	elif is_planted and growth_stage < max_growth_stage:
		var day_night_timer = get_node("/root/Garden/DayNightCycle") 
		var modifier = day_night_timer.weather_growth_modifiers[current_weather]
		$PetuniaTimer.wait_time = growth_time * modifier
		$PetuniaTimer.start()
		$PetuniaPanel/PetuniaLabel.text = "It's growing!"
		print("Defferred growth started with initial wait time: ", $PetuniaTimer.wait_time, "s, under ", current_weather, " weather.")
		if current_weather == "rainy":
				$PetuniaPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $PetuniaTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$PetuniaTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$PetuniaTimer.start()
				else:
					$PetuniaTimer.wait_time = $PetuniaTimer.time_left - rain_bonus
					$PetuniaTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $PetuniaTimer.wait_time)
					
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
		$PetuniaTimer.wait_time = growth_time * modifier
		$PetuniaTimer.start()
		$PetuniaPanel/WaterButton.disabled = false
		$PetuniaPanel/PruneButton.disabled = true
		$PetuniaPanel/FertilizerButton.disabled = false
		$PetuniaPanel/PetuniaLabel.text = "It's growing!"
		print("Growth started with initial wait time: ", $PetuniaTimer.wait_time, "s, under ", current_weather, " weather.")
		if current_weather == "rainy":
				$PetuniaPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $PetuniaTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$PetuniaTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$PetuniaTimer.start()
				else:
					$PetuniaTimer.wait_time = $PetuniaTimer.time_left - rain_bonus
					$PetuniaTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $PetuniaTimer.wait_time)
	else:
		is_day =  true
		$PetuniaPanel/WaterButton.disabled = true
		$PetuniaPanel/PruneButton.disabled = true
		$PetuniaPanel/FertilizerButton.disabled = true
		$PetuniaPanel/PetuniaLabel.text = "Doesn't grow in sunlight"
		print("Petunia timer defferred")
	
func _on_petunia_timer_timeout():
	growth_stage += 1
	update_plant_appearance()
	print("Petunia timer timeout, growth stage: ", growth_stage)
	if growth_stage >= max_growth_stage:
		growth_stage = max_growth_stage
		print("Flower is fully grown")
		$PetuniaTimer.stop()
	else:
		var day_night_timer = get_node("/root/Garden/DayNightCycle")
		var current_weather = day_night_timer.current_weather
		var modifier = weather_growth_modifiers[current_weather]
		$PetuniaTimer.wait_time = growth_time * modifier
		$PetuniaTimer.start()  # Restart the timer with the new wait time
		print("The flower grew")
		print("Petunia timer restarted with new wait time: ", $PetuniaTimer.wait_time, ", for growth stage: ", growth_stage)
	
func update_plant_appearance():
	# Update the plant's sprite based on its growth stage
	if growth_stage == 1:
		$PetuniaPanel/PruneButton.disabled = false
		self.texture_normal = load("res://art/PhantomPetuniaSprout.png")
		self.texture_hover = load("res://art/PhantomPetuniaSproutHover.png")
		self.position = position + petunia_sprout_offset
		$PetuniaPanel.position = position + petunia_panel_offset
		print("Growth stage: ", growth_stage)
	elif growth_stage == 2:
		$PetuniaPanel.hide()
		self.texture_normal = load("res://art/PhantomPetuniaFlower.png")
		self.texture_hover = load("res://art/PhantomPetuniaFlowerHover.png")
		self.position = position + petunia_offset
		print("Growth stage: ", growth_stage)

func _on_phantom_petunia_pressed():
	if Global.selected_pot and seed_name == "PhantomPetunia" and not is_planted:
		Global.selected_pot.plant_seed(seed_name)
		emit_signal("seed_planted", seed_name)
		Global.remove_seed_from_inventory(seed_name)
	elif growth_stage >= max_growth_stage:
		var global_script = get_node("/root/Global")
		global_script.add_currency(petunia_value)
		self.queue_free()
		print("Sold ", seed_name)
	else:
		print("Petunia already planted")
		$PetuniaPanel.show()

func _on_water_button_pressed():
	var time_left_after_reduction = $PetuniaTimer.time_left - water_timer_deduct
	if ($PetuniaTimer.time_left > 0):
		$PetuniaPanel/WaterButton.disabled = true
		$WaterSound.play()
		$WaterParticles.emitting = true
		$WaterTimer.start()
		if time_left_after_reduction <= 0:
			$PetuniaTimer.wait_time = 0.01
			print("Flower watered - ", water_timer_deduct, "s = reached next stage")
			$PetuniaTimer.start()
		else:
			$PetuniaTimer.wait_time = time_left_after_reduction
			$PetuniaTimer.start()
			print("Flower watered - ", water_timer_deduct, "s = ", $PetuniaTimer.wait_time)	
	if growth_stage == 0:
		$WaterParticles.lifetime = 0.4
	if growth_stage == 1:
		$WaterParticles.lifetime = 0.6
	
func _on_water_timer_timeout():
	var day_night_timer = get_node("/root/Garden/DayNightCycle")
	var current_weather = day_night_timer.current_weather
	if not is_day and current_weather != "rainy":
		$PetuniaPanel/WaterButton.disabled = false

func _on_fertilizer_button_pressed():
	var time_left_after_reduction = $PetuniaTimer.time_left - fertilizer_timer_deduct
	if ($PetuniaTimer.time_left > 0):
		$PetuniaPanel/FertilizerButton.disabled = true
		$FertilizerSound.play()
		$FertilizerParticles.emitting = true
		if time_left_after_reduction <= 0:
			$PetuniaTimer.wait_time = 0.01
			print("Flower fertilized - ", fertilizer_timer_deduct, "s = reached next stage")
			$PetuniaTimer.start()
		else:
			$PetuniaTimer.wait_time = time_left_after_reduction
			$PetuniaTimer.start()
			print("Flower fertilized - ", fertilizer_timer_deduct, "s = ", $PetuniaTimer.wait_time)	
	if growth_stage == 0:
		$FertilizerParticles.lifetime = 0.4
	if growth_stage == 1:
		$FertilizerParticles.lifetime = 0.6
	
func _on_prune_button_pressed():
	var time_left_after_reduction = $PetuniaTimer.time_left - prune_timer_deduct
	if ($PetuniaTimer.time_left > 0):
		$PetuniaPanel/PruneButton.disabled = true
		$PruneSound.play()
		$PruneTimer.start()
		if time_left_after_reduction <= 0:
			$PetuniaTimer.wait_time = 0.01
			print("Flower pruned - ", prune_timer_deduct, "s = reached next stage")
			$PetuniaTimer.start()
		else:
			$PetuniaTimer.wait_time = time_left_after_reduction
			$PetuniaTimer.start()
		print("Flower pruned - ", prune_timer_deduct, "s = ", $PetuniaTimer.wait_time)	

func _on_prune_timer_timeout():
	if not is_day:
		$PetuniaPanel/PruneButton.disabled = false
		print("prune button enabled")

func _on_close_button_pressed():
	$PetuniaPanel.hide()
