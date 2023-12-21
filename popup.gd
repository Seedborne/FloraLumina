extends PopupPanel

var inventory = preload("res://global.gd")  # Adjust the path to your SeedInventory script
signal seed_planted(seed_name)

func _ready():
	Global.connect("inventory_updated", _refresh_inventory_display)
	_refresh_inventory_display()
	
func _refresh_inventory_display():
	print("refresh inventory")
	var hbox = get_node("/root/Garden/UI/SeedPopup/SeedPopupContainer")
	# Clear existing buttons or disable them
	for button in hbox.get_children():
		if button is TextureButton: # or however you determine it's a seed button
			button.queue_free() # or disable it
	# Create buttons for each seed in inventory
	for seed_name in Global.seed_inventory.keys():
		if Global.get_seed_count(seed_name) > 0:
			var seed_count = Global.get_seed_count(seed_name)
			for i in range(min(seed_count, 10)):
				var FlowerScene = load("res://" + seed_name + ".tscn")
				var seed_button = FlowerScene.instantiate()
			# Set up the seed button (text, connect signals, etc.)
				seed_button.texture_normal = load("res://art/" + seed_name + "Seed.png")
				hbox.add_child(seed_button)
				seed_button.connect("pressed", _on_seed_button_pressed)
				print("added seed")
			# Set the button to visible or enabled
				seed_button.show() # or set disabled to false
	# Optionally, set up other seed buttons based on available seeds in the inventory
	
func _on_seed_button_pressed():
	hide()
	_refresh_inventory_display()

