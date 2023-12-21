extends TextureButton

const MAX_SEEDS = 10
var cost = 18
var seed_name = "BlazingSnapdragon"
@onready var buy_sound = get_node("/root/Garden/BuySeedSound")

func _on_pressed():
	var global_script = get_node("/root/Global") # Adjust the path to your global node
	var global_script2 = get_node("/root/Global")
	var current_currency = global_script.get_currency()
	var total_seeds = global_script2.get_total_seed_count()
	if current_currency >= cost:
		if total_seeds < MAX_SEEDS:
			global_script.spend_currency(cost)
			global_script.add_seed_to_inventory(seed_name, 1)
			buy_sound.play()
			# Optional: Give feedback to the player
			print("Purchased ", seed_name)
		else:
			print("Max seed inventory reached")
	else:
		# Optional: Notify player of insufficient funds
		print("Not enough currency to purchase ", seed_name)
