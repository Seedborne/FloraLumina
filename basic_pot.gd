extends TextureButton

signal inventory_updated
signal seed_planted_in_pot(seed_instance)
var is_planted = false
@onready var seed_popup = get_node("/root/Garden/UI/SeedPopup")

func _ready():
	if not Global.is_step_completed("open_seed_inventory"):
		$SeedInventoryTutorial.show()
		
func _on_pressed():
	Global.set_selected_pot(self)
	if not Global.is_step_completed("plant_seed"):
		Global.mark_step_completed("open_seed_inventory")
		$SeedInventoryTutorial.hide()
		$PlantSeedTutorial.show()
	if not is_planted:
		emit_signal("inventory_updated")
		print("open seed inventory")
		seed_popup.show()
	else:
		print("already planted")

func _on_seed_selected(seed_name):
	plant_seed(seed_name)
	print("seed selected")

func plant_seed(seed_name: String):
	if not Global.is_step_completed("tend_seed"):
		$PlantSeedTutorial.hide()
		Global.mark_step_completed("plant_seed")
	if not is_planted:
		$PlantSeedSound.play()
		var seed_instance = load("res://" + seed_name + ".tscn").instantiate()
		if Global.selected_pot:
			Global.selected_pot.add_child(seed_instance)
			self.connect("seed_planted_in_pot", Callable(seed_instance, "_start_growth"))
			emit_signal("seed_planted_in_pot", seed_instance)
			is_planted = true
			self.texture_normal = load("res://art/PlantedPotSprite.png")
			self.texture_hover = load("res://art/PlantedPotSprite.png")
		
func _on_child_exiting_tree(_node):
	is_planted = false
	self.texture_normal = load("res://art/BasicPotSprite.png")
	self.texture_hover = load("res://art/BasicPotSpriteLight.png")
	print("pot reset")
