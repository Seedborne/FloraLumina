extends TextureButton

signal seed_planted(seed_name)
var seed_name = "BlazingSnapdragon"
var snapdragon_value = 65
var is_planted = false
var growth_stage = 0
var max_growth_stage = 2
var growth_time = 300.0  # Seconds to grow to next stage
var snapdragon_sprout_offset = Vector2(-5, -160)
var snapdragon_offset = Vector2(-20, -70)
var snapdragon_panel_offset = Vector2(-470, 1150)
var snapdragon_visible = false
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
@onready var timer = $SnapdragonTimer

func _ready():
	add_to_group("blazing_snapdragons")
	var day_night_timer = get_node("/root/Garden/DayNightCycle") # Adjust the path if it's different
	day_night_timer.connect("day_night_changed", _on_day_night_changed)
	day_night_timer.connect("weather_changed", _on_weather_changed)

func _on_day_night_changed(is_daytime):
	if is_daytime:
		is_day = true
		$SnapdragonPanel/WaterButton.disabled = false
		$SnapdragonPanel/FertilizerButton.disabled = false
		if ($SnapdragonTimer.time_left > 0):
			$SnapdragonTimer.paused = false
			$SnapdragonPanel/SnapdragonLabel.text = "It's growing!"
			print("Snapdragon timer resumed")
		if growth_stage == 1:
			$SnapdragonPanel/PruneButton.disabled = false
	else:
		is_day = false
		$SnapdragonPanel/WaterButton.disabled = true
		$SnapdragonPanel/FertilizerButton.disabled = true
		$SnapdragonPanel/PruneButton.disabled = true
		if ($SnapdragonTimer.time_left > 0):
			$SnapdragonTimer.paused = true
			$SnapdragonPanel/SnapdragonLabel.text = "Doesn't grow in moonlight"
			print("Snapdragon timer paused")
	
func _on_weather_changed(current_weather):
	if ($SnapdragonTimer.time_left > 0):
		if is_day:
			var remaining_time = $SnapdragonTimer.time_left
			var modifier = weather_growth_modifiers[current_weather]
			$SnapdragonTimer.wait_time = remaining_time * modifier
			$SnapdragonTimer.start()
			print("Weather changed to ", current_weather, " modifier applied: ", modifier, ". New wait time: ", $SnapdragonTimer.wait_time)
			if current_weather == "rainy":
				$SnapdragonPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $SnapdragonTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$SnapdragonTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$SnapdragonTimer.start()
				else:
					$SnapdragonTimer.wait_time = $SnapdragonTimer.time_left - rain_bonus
					$SnapdragonTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $SnapdragonTimer.wait_time)
		else:
			print("Snapdragon timer paused. Remaining time: ", $SnapdragonTimer.time_left)
	elif is_planted and growth_stage < max_growth_stage:
		var day_night_timer = get_node("/root/Garden/DayNightCycle") 
		var modifier = day_night_timer.weather_growth_modifiers[current_weather]
		$SnapdragonTimer.wait_time = growth_time * modifier
		$SnapdragonTimer.start()
		$SnapdragonPanel/SnapdragonLabel.text = "It's growing!"
		print("Defferred growth started with initial wait time: ", $SnapdragonTimer.wait_time, "s, under ", current_weather, " weather.")
		if current_weather == "rainy":
				$SnapdragonPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $SnapdragonTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$SnapdragonTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$SnapdragonTimer.start()
				else:
					$SnapdragonTimer.wait_time = $SnapdragonTimer.time_left - rain_bonus
					$SnapdragonTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $SnapdragonTimer.wait_time)
					
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
		$SnapdragonTimer.wait_time = growth_time * modifier
		$SnapdragonTimer.start()
		$SnapdragonPanel/WaterButton.disabled = false
		$SnapdragonPanel/FertilizerButton.disabled = false
		$SnapdragonPanel/PruneButton.disabled = true
		$SnapdragonPanel/SnapdragonLabel.text = "It's growing!"
		print("Growth started with initial wait time: ", $SnapdragonTimer.wait_time, "s, under ", current_weather, " weather.")
		if current_weather == "rainy":
				$SnapdragonPanel/WaterButton.disabled = true
				var rain_bonus = 20
				var time_left_after_rain_bonus = $SnapdragonTimer.time_left - rain_bonus
				if time_left_after_rain_bonus <= 0:
					$SnapdragonTimer.wait_time = 0.01
					print("Flower rained on -20s, reached next stage")
					$SnapdragonTimer.start()
				else:
					$SnapdragonTimer.wait_time = $SnapdragonTimer.time_left - rain_bonus
					$SnapdragonTimer.start()
					print("Rainy weather bonus applied -20s New wait time: ", $SnapdragonTimer.wait_time)
	else:
		is_day =  false
		$SnapdragonPanel/WaterButton.disabled = true
		$SnapdragonPanel/FertilizerButton.disabled = true
		$SnapdragonPanel/PruneButton.disabled = true
		$SnapdragonPanel/SnapdragonLabel.text = "Doesn't grow in moonlight"
		print("Snapdragon timer defferred")
	
func _on_snapdragon_timer_timeout():
	growth_stage += 1
	update_plant_appearance()
	print("Snapdragon timer timeout, growth stage: ", growth_stage)
	if growth_stage >= max_growth_stage:
		growth_stage = max_growth_stage
		print("Flower is fully grown")
		$SnapdragonTimer.stop()
	else:
		var day_night_timer = get_node("/root/Garden/DayNightCycle")
		var current_weather = day_night_timer.current_weather
		var modifier = weather_growth_modifiers[current_weather]
		$SnapdragonTimer.wait_time = growth_time * modifier
		$SnapdragonTimer.start()  # Restart the timer with the new wait time
		print("The flower grew")
		print("Snapdragon timer restarted with new wait time: ", $SnapdragonTimer.wait_time, ", for growth stage: ", growth_stage)
	
func update_plant_appearance():
	# Update the plant's sprite based on its growth stage
	if growth_stage == 1:
		$SnapdragonPanel/PruneButton.disabled = false
		self.texture_normal = load("res://art/BlazingSnapdragonSprout.png")
		self.texture_hover = load("res://art/BlazingSnapdragonSproutHover.png")
		self.position = position + snapdragon_sprout_offset
		$SnapdragonPanel.position = position + snapdragon_panel_offset
		print("Growth stage: ", growth_stage)
	elif growth_stage == 2:
		$SnapdragonPanel.hide()
		self.texture_normal = load("res://art/BlazingSnapdragonFlower.png")
		self.texture_hover = load("res://art/BlazingSnapdragonFlowerHover.png")
		self.position = position + snapdragon_offset
		print("Growth stage: ", growth_stage)

func _on_blazing_snapdragon_pressed():
	if Global.selected_pot and seed_name == "BlazingSnapdragon" and not is_planted:
		Global.selected_pot.plant_seed(seed_name)
		emit_signal("seed_planted", seed_name)
		Global.remove_seed_from_inventory(seed_name)
	elif growth_stage >= max_growth_stage:
		var global_script = get_node("/root/Global")
		global_script.add_currency(snapdragon_value)
		self.queue_free()
		print("Sold ", seed_name)
	else:
		print("Snapdragon already planted")
		$SnapdragonPanel.show()

func _on_water_button_pressed():
	var time_left_after_reduction = $SnapdragonTimer.time_left - water_timer_deduct
	if ($SnapdragonTimer.time_left > 0):
		$SnapdragonPanel/WaterButton.disabled = true
		$WaterSound.play()
		$WaterParticles.emitting = true
		$WaterTimer.start()
		if time_left_after_reduction <= 0:
			$SnapdragonTimer.wait_time = 0.01
			print("Flower watered - ", water_timer_deduct, "s = reached next stage")
			$SnapdragonTimer.start()
		else:
			$SnapdragonTimer.wait_time = time_left_after_reduction
			$SnapdragonTimer.start()
			print("Flower watered - ", water_timer_deduct, "s = ", $SnapdragonTimer.wait_time)	
	if growth_stage == 0:
		$WaterParticles.lifetime = 0.4
	if growth_stage == 1:
		$WaterParticles.lifetime = 0.6

func _on_water_timer_timeout():
	var day_night_timer = get_node("/root/Garden/DayNightCycle")
	var current_weather = day_night_timer.current_weather
	if is_day and current_weather != "rainy":
		$SnapdragonPanel/WaterButton.disabled = false

func _on_fertilizer_button_pressed():
	var time_left_after_reduction = $SnapdragonTimer.time_left - fertilizer_timer_deduct
	if ($SnapdragonTimer.time_left > 0):
		$SnapdragonPanel/FertilizerButton.disabled = true
		$FertilizerSound.play()
		$FertilizerParticles.emitting = true
		if time_left_after_reduction <= 0:
			$SnapdragonTimer.wait_time = 0.01
			print("Flower watered - ", fertilizer_timer_deduct, "s = reached next stage")
			$SnapdragonTimer.start()
		else:
			$SnapdragonTimer.wait_time = time_left_after_reduction
			$SnapdragonTimer.start()
			print("Flower fertilized - ", fertilizer_timer_deduct, "s = ", $SnapdragonTimer.wait_time)	
	if growth_stage == 0:
		$FertilizerParticles.lifetime = 0.4
	if growth_stage == 1:
		$FertilizerParticles.lifetime = 0.6
	
func _on_prune_button_pressed():
	var time_left_after_reduction = $SnapdragonTimer.time_left - prune_timer_deduct
	if ($SnapdragonTimer.time_left > 0):
		$SnapdragonPanel/PruneButton.disabled = true
		$PruneSound.play()
		$PruneTimer.start()
		if time_left_after_reduction <= 0:
			$SnapdragonTimer.wait_time = 0.01
			print("Flower pruned - ", prune_timer_deduct, "s = reached next stage")
			$SnapdragonTimer.start()
		else:
			$SnapdragonTimer.wait_time = time_left_after_reduction
			$SnapdragonTimer.start()
		print("Flower pruned - ", prune_timer_deduct, "s = ", $SnapdragonTimer.wait_time)	

func _on_prune_timer_timeout():
	if is_day:
		$SnapdragonPanel/PruneButton.disabled = false
		print("prune button enabled")

func _on_close_button_pressed():
	$SnapdragonPanel.hide()
