extends CanvasLayer

var plant_inventory_visible = false
var shop_visible = false

@onready var currency_label = $CurrencyLabel # Make sure to set the correct path to your currency label

func _ready():
	# Connect the global script signal to the local update function
	var global_script = get_node("/root/Global")
	global_script.connect("currency_changed", _on_currency_changed)
	# Initialize the display
	_on_currency_changed(global_script.get_currency())
	
func _process(_delta):
	if Global.is_step_completed("sell_flower") and not Global.is_step_completed("open_shop"):
			Global.mark_step_completed("open_shop")
			$ShopButton/OpenShopTutorial.show()

# Callback function to update currency display
func _on_currency_changed(new_currency_amount: int) -> void:
	currency_label.text = str("$", new_currency_amount)
	
func _on_shop_button_pressed():
	shop_visible = !shop_visible
	$ShopButton/ShopPanel.visible = shop_visible
	if Global.is_step_completed("open_shop") and not Global.is_step_completed("in_shop"):
		$ShopButton/OpenShopTutorial.hide()
		$ShopButton/ShopPanel/BuySeedsTutorial.show()

func _on_close_shop_pressed():
	shop_visible = !shop_visible
	$ShopButton/ShopPanel.visible = shop_visible
	if Global.is_step_completed("open_shop"):
		Global.mark_step_completed("in_shop")
		$ShopButton/ShopPanel/BuySeedsTutorial.hide()
	

