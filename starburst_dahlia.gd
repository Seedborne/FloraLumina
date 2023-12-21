extends TextureButton

signal seed_planted(seed_name)
var seed_name = "StarburstDahlia"
var dahlia_value = 36
var is_planted = false
var growth_stage = 0
var max_growth_stage = 2
var growth_time = 200.0  # Seconds to grow to next stage
var dahlia_sprout_offset = Vector2(15, -106)
var dahlia_offset = Vector2(-24, -33)
var dahlia_panel_offset = Vector2(-550, 830)
var dahlia_visible = false
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
@onready var timer = $DahliaTimer

func _ready():
	add_to_group("starburst_dahlias")
	var day_night_timer = get_node("/root/Garden/DayNightCycle") # Adjust the path if it's different
	day_night_timer.connect("day_night_changed", _on_day_night_changed)
	day_night_timer.connect("weather_changed", _on_weather_changed)
	
func _on_day_night_changed(is_daytime):
	if is_daytime:
		is_day = true
		$DahliaPanel/WaterButton.disabled = true
		$DahliaPanel/FertilizerButton.disabled = true
		$DahliaPanel/PruneButton.disabled = true
		if ($DahliaTimer.time_left > 0):
			$DahliaTimer.paused = true
			$DahliaPanel/DahliaLabel.text = "Doesn't grow in sunlight"
			print("Dahlia timer paused")
		
	else:
		is_day = false
		$DahliaPanel/WaterButton.disabled = false
		$DahliaPanel/FertilizerButton.disabled = false
		if ($DahliaTimer.time_left > 0):
			$DahliaTimer.paused = false
			$DahliaPanel/DahliaLabel.text = "It's growing!"
			print("Dahlia timer resumed")
		if growth_stage == 1:
			$DahliaPanel/PruneButton.disabled = false
			
func _on_weather_changed(current_weather):
	if ($DahliaTimer.time_left > 0):
		if not is_day:
			var remaining_time = $DahliaTimer.time_left
			var modifier = weather_growth_modifiers[current_weather]
			$DahliaTimer.wait_time = remaining_time * modifier
			$DahliaTimer.start()
			print("Weather changed to ", current_weather, ", modifier applied: ", modifier, ". New wait time: ", $DahliaTimer.wait_time)
			if current_weather == "rainy":
				$DahliaPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $DahliaTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$DahliaTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$DahliaTimer.start()
				else:
					$DahliaTimer.wait_time = $DahliaTimer.time_left - rain_bonus
					$DahliaTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $DahliaTimer.wait_time)
		else:
			print("Dahlia timer paused. Remaining time: ", $DahliaTimer.time_left)
	elif is_planted and growth_stage < max_growth_stage:
		var day_night_timer = get_node("/root/Garden/DayNightCycle") 
		var modifier = day_night_timer.weather_growth_modifiers[current_weather]
		$DahliaTimer.wait_time = growth_time * modifier
		$DahliaTimer.start()
		$DahliaPanel/DahliaLabel.text = "It's growing!"
		print("Defferred growth started with initial wait time: ", $DahliaTimer.wait_time, "s, under ", current_weather, " weather.")
		if current_weather == "rainy":
				$DahliaPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $DahliaTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$DahliaTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$DahliaTimer.start()
				else:
					$DahliaTimer.wait_time = $DahliaTimer.time_left - rain_bonus
					$DahliaTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $DahliaTimer.wait_time)
					
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
		$DahliaTimer.wait_time = growth_time * modifier
		$DahliaTimer.start()
		$DahliaPanel/WaterButton.disabled = false
		$DahliaPanel/PruneButton.disabled = true
		$DahliaPanel/FertilizerButton.disabled = false
		$DahliaPanel/DahliaLabel.text = "It's growing!"
		print("Growth started with initial wait time: ", $DahliaTimer.wait_time, "s, under ", current_weather, " weather.")
		if current_weather == "rainy":
				$DahliaPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $DahliaTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$DahliaTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$DahliaTimer.start()
				else:
					$DahliaTimer.wait_time = $DahliaTimer.time_left - rain_bonus
					$DahliaTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $DahliaTimer.wait_time)
	else:
		is_day =  true
		$DahliaPanel/WaterButton.disabled = true
		$DahliaPanel/PruneButton.disabled = true
		$DahliaPanel/FertilizerButton.disabled = true
		$DahliaPanel/DahliaLabel.text = "Doesn't grow in sunlight"
		print("Dahlia timer defferred")
	
func _on_dahlia_timer_timeout():
	growth_stage += 1
	update_plant_appearance()
	print("Dahlia timer timeout, growth stage: ", growth_stage)
	if growth_stage >= max_growth_stage:
		growth_stage = max_growth_stage
		print("Flower is fully grown")
		$DahliaTimer.stop()
	else:
		var day_night_timer = get_node("/root/Garden/DayNightCycle")
		var current_weather = day_night_timer.current_weather
		var modifier = weather_growth_modifiers[current_weather]
		$DahliaTimer.wait_time = growth_time * modifier
		$DahliaTimer.start()  # Restart the timer with the new wait time
		print("The flower grew")
		print("Dahlia timer restarted with new wait time: ", $DahliaTimer.wait_time, ", for growth stage: ", growth_stage)
	
func update_plant_appearance():
	# Update the plant's sprite based on its growth stage
	if growth_stage == 1:
		$DahliaPanel/PruneButton.disabled = false
		self.texture_normal = load("res://art/StarburstDahliaSprout.png")
		self.texture_hover = load("res://art/StarburstDahliaSproutHover.png")
		self.position = position + dahlia_sprout_offset
		$DahliaPanel.position = position + dahlia_panel_offset
		print("Growth stage: ", growth_stage)
	elif growth_stage == 2:
		$DahliaPanel.hide()
		self.texture_normal = load("res://art/StarburstDahliaFlower.png")
		self.texture_hover = load("res://art/StarburstDahliaFlowerHover.png")
		self.position = position + dahlia_offset
		print("Growth stage: ", growth_stage)

func _on_starburst_dahlia_pressed():
	if Global.selected_pot and seed_name == "StarburstDahlia" and not is_planted:
		Global.selected_pot.plant_seed(seed_name)
		emit_signal("seed_planted", seed_name)
		Global.remove_seed_from_inventory(seed_name)
	elif growth_stage >= max_growth_stage:
		var global_script = get_node("/root/Global")
		global_script.add_currency(dahlia_value)
		self.queue_free()
		print("Sold ", seed_name)
	else:
		print("Dahlia already planted")
		$DahliaPanel.show()

func _on_water_button_pressed():
	var time_left_after_reduction = $DahliaTimer.time_left - water_timer_deduct
	if ($DahliaTimer.time_left > 0):
		$DahliaPanel/WaterButton.disabled = true
		$WaterSound.play()
		$WaterParticles.emitting = true
		$WaterTimer.start()
		if time_left_after_reduction <= 0:
			$DahliaTimer.wait_time = 0.01
			print("Flower watered - ", water_timer_deduct, "s = reached next stage")
			$DahliaTimer.start()
		else:
			$DahliaTimer.wait_time = time_left_after_reduction
			$DahliaTimer.start()
			print("Flower watered - ", water_timer_deduct, "s = ", $DahliaTimer.wait_time)	
	if growth_stage == 0:
		$WaterParticles.lifetime = 0.4
	if growth_stage == 1:
		$WaterParticles.lifetime = 0.6
	
func _on_water_timer_timeout():
	var day_night_timer = get_node("/root/Garden/DayNightCycle")
	var current_weather = day_night_timer.current_weather
	if not is_day and current_weather != "rainy":
		$DahliaPanel/WaterButton.disabled = false

func _on_fertilizer_button_pressed():
	var time_left_after_reduction = $DahliaTimer.time_left - fertilizer_timer_deduct
	if ($DahliaTimer.time_left > 0):
		$DahliaPanel/FertilizerButton.disabled = true
		$FertilizerSound.play()
		$FertilizerParticles.emitting = true
		if time_left_after_reduction <= 0:
			$DahliaTimer.wait_time = 0.01
			print("Flower fertilized - ", fertilizer_timer_deduct, "s = reached next stage")
			$DahliaTimer.start()
		else:
			$DahliaTimer.wait_time = time_left_after_reduction
			$DahliaTimer.start()
			print("Flower fertilized - ", fertilizer_timer_deduct, "s = ", $DahliaTimer.wait_time)	
	if growth_stage == 0:
		$FertilizerParticles.lifetime = 0.4
	if growth_stage == 1:
		$FertilizerParticles.lifetime = 0.6
	
func _on_prune_button_pressed():
	var time_left_after_reduction = $DahliaTimer.time_left - prune_timer_deduct
	if ($DahliaTimer.time_left > 0):
		$DahliaPanel/PruneButton.disabled = true
		$PruneSound.play()
		$PruneTimer.start()
		if time_left_after_reduction <= 0:
			$DahliaTimer.wait_time = 0.01
			print("Flower pruned - ", prune_timer_deduct, "s = reached next stage")
			$DahliaTimer.start()
		else:
			$DahliaTimer.wait_time = time_left_after_reduction
			$DahliaTimer.start()
		print("Flower pruned - ", prune_timer_deduct, "s = ", $DahliaTimer.wait_time)	

func _on_prune_timer_timeout():
	if not is_day:
		$DahliaPanel/PruneButton.disabled = false
		print("prune button enabled")

func _on_close_button_pressed():
	$DahliaPanel.hide()
