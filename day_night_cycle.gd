extends Timer

var is_daytime = true
var weather_conditions = ["clear", "par_cloudy", "cloudy", "rainy", "snowy"]
var current_weather = "par_cloudy"
var weather_growth_modifiers = {
	"clear": 0.75, # Clear weather speeds up growth by 25%
	"par_cloudy": 1.0, # Clear weather speeds up growth by 25%
	"cloudy": 1.25, # Cloudy weather slows down growth by 25%
	"rainy": 1.25, #Rainy weather slows down growth by 25%
	"snowy": 1.5, # Snowy weather slows down growth by 50%
}
@onready var background_node = get_node("/root/Garden/GardenBackground")
@onready var rain_particles = get_node("/root/Garden/GardenBackground/RainParticles")
@onready var snow_particles = get_node("/root/Garden/GardenBackground/SnowParticles")
@onready var day_music = get_node("/root/Garden/DayMusic")
@onready var day_sounds = get_node("/root/Garden/DaySounds")
@onready var night_music = get_node("/root/Garden/NightMusic")
@onready var night_sounds = get_node("/root/Garden/NightSounds")
@onready var rain_sounds = get_node("/root/Garden/RainSounds")
@onready var snow_sounds = get_node("/root/Garden/SnowSounds")
signal weather_changed(current_weather)
signal day_night_changed

# Timer for the clock update.
var clock_timer = Timer.new()
# Start at 7:00 AM in game time.
var hour = 7
var minutes = 0
var is_am = true
@onready var clock_label = get_node("/root/Garden/UI/ClockLabel")
@onready var weather_label = get_node("/root/Garden/UI/WeatherLabel")

func _ready():
	day_music.play()
	day_sounds.play()
	add_child(clock_timer)
	clock_timer.wait_time = 5
	clock_timer.start()
	clock_timer.connect("timeout", _on_clock_timer_timeout)
	update_clock_label()
	update_weather_label()
	
func _on_timeout():
	is_daytime = !is_daytime
	if is_daytime:
		current_weather = weather_conditions[randi() % weather_conditions.size()]
		night_music.stop()
		night_sounds.stop()
		day_music.play()
		day_sounds.play()
		change_background()
		update_weather_label()
		print("It's now daytime.")
	else:
		print("It's now nighttime.")
		current_weather = weather_conditions[randi() % weather_conditions.size()]
		day_music.stop()
		day_sounds.stop()
		night_music.play()
		night_sounds.play()
		change_background()
		update_weather_label()
	# Notify other nodes about the time change
	emit_signal("day_night_changed", is_daytime)
	emit_signal("weather_changed", current_weather)
	if not Global.is_step_completed("first_night"):
		$NightTutorialPanel.show()
		Global.mark_step_completed("first_night")
	
func _on_clock_timer_timeout():
	# Add 30 minutes to the clock every 5 seconds.
	minutes += 30
	if minutes >= 60:
		minutes = 0
		hour += 1
	# Switch AM to PM or PM to AM at 12 o'clock
	if hour == 12 and minutes == 0:
		is_am = !is_am
	if hour == 13:
		hour = 1
	update_clock_label()

func update_clock_label():
	var am_pm = "AM" if is_am else "PM"
	var time_string = "%d:%02d %s" % [hour, minutes, am_pm]
	clock_label.text = time_string
	print(time_string)

func update_weather_label():
	if current_weather == "par_cloudy":
		weather_label.text = "Partly Cloudy"
	elif current_weather == "cloudy":
		weather_label.text = "Cloudy"
	elif current_weather == "clear":
		weather_label.text = "Clear"
	elif current_weather == "rainy":
		weather_label.text = "Rainy"
	elif current_weather == "snowy":
		weather_label.text = "Snowy"

func change_background():
	var time_of_day = "day" if is_daytime else "night"
	var background_image = time_of_day + "_" + current_weather + ".png"
	background_node.texture = load("res://art/" + background_image)
	rain_particles.emitting = current_weather == "rainy"
	snow_particles.emitting = current_weather == "snowy"
	if current_weather == "clear":
		snow_particles.visible = false
		rain_particles.visible = false
		rain_sounds.stop()
		snow_sounds.stop()
	elif current_weather == "par_cloudy":
		snow_particles.visible = false
		rain_particles.visible = false
		rain_sounds.stop()
		snow_sounds.stop()
	elif current_weather == "cloudy":
		snow_particles.visible = false
		rain_particles.visible = false
		rain_sounds.stop()
		snow_sounds.stop()
	elif current_weather == "rainy":
		snow_particles.visible = false
		rain_particles.visible = true
		snow_sounds.stop()
		day_sounds.stop()
		night_sounds.stop()
		rain_sounds.play()
	elif current_weather == "snowy":
		snow_particles.visible = true
		rain_particles.visible = false
		rain_sounds.stop()
		day_sounds.stop()
		night_sounds.stop()
		snow_sounds.play()
	print("The weather is ", current_weather)


func _on_close_tutorial_pressed():
	$NightTutorialPanel.hide()
