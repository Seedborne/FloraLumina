extends Node

const MAX_SEEDS = 10
var is_daytime = true
signal inventory_updated
signal currency_changed(currency_amount)
var seed_inventory = {
	"RadiantDaisy": 0,
	"AzureBell": 0,
	"ZephyrZinnia": 0,
	"SolarflareRose": 0,
	"BlazingSnapdragon": 0,
	"LunarTulip": 0,
	"PhantomPetunia": 0,
	"TwilightLily": 0,
	"StarburstDahlia": 0,
	"BlackLotus": 0,
	# Add other seeds as necessary.
}
var player_currency: int = 0
var selected_pot = null
var tutorial_steps_completed = {
	"open_seed_inventory": false,
	"plant_seed": false,
	"tend_seed": false,
	"water_seed": false,
	"fertilize_seed": false,
	"unlock_plot": false,
	"first_flower": false,
	"sell_flower": false,
	"open_shop": false,
	"in_shop": false,
	"first_night": false,
	# Add other tutorial steps as needed.
}

func _ready():
	# Initialize the inventory with one daisy seed when the game starts
	seed_inventory["RadiantDaisy"] = 1
	# Notify that inventory is updated
	emit_signal("inventory_updated")
	print(seed_inventory)
	

func mark_step_completed(step_name):
	tutorial_steps_completed[step_name] = true

func is_step_completed(step_name) -> bool:
	return tutorial_steps_completed.get(step_name, false)
	
func add_currency(amount: int) -> void:
	player_currency += amount
	# Emit a signal to update any UI elements that display currency
	emit_signal("currency_changed", player_currency)
	$"/root/SellAudio".play()
	# You could also add checks to ensure currency doesn't go below 0
	# or above a maximum value, depending on your game design.

# Function to spend currency, returns true if successful, false if not enough currency
func spend_currency(amount: int) -> bool:
	if player_currency >= amount:
		player_currency -= amount
		emit_signal("currency_changed", player_currency)
		return true
	else:
		# Not enough currency to spend
		return false
# Function to get the current currency value
func get_currency() -> int:
	return player_currency
	
func add_seed_to_inventory(seed_name: String, count: int = 1):
	var current_total_seeds = get_total_seed_count()
	if current_total_seeds + count > MAX_SEEDS:
		print("Cannot add more seeds. Inventory limit reached, ", seed_inventory)
		return  # Optionally, you could add only the number of seeds that fit within the limit
	seed_inventory[seed_name] = seed_inventory.get(seed_name, 0) + count
	emit_signal("inventory_updated")
	print(seed_inventory)
	
func get_total_seed_count() -> int:
	var total = 0
	for key in seed_inventory.keys():
		total += seed_inventory[key]
	return total
		
func remove_seed_from_inventory(seed_name: String, count: int = 1):
	seed_inventory[seed_name] = seed_inventory.get(seed_name, 0) - count
	emit_signal("inventory_updated")
	print(seed_inventory)

func get_seed_count(seed_name: String) -> int:
	return seed_inventory.get(seed_name, 0)

func set_selected_pot(pot_instance):
	selected_pot = pot_instance
	

