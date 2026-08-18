extends Control 

signal resonance_structures_pressed
signal options_menu_requested
signal quit_requested

func _on_resonance_structures_button_pressed() -> void:
	resonance_structures_pressed.emit()

func _on_options_button_pressed() -> void:
	options_menu_requested.emit()

func _on_quit_button_pressed() -> void:
	quit_requested.emit()
