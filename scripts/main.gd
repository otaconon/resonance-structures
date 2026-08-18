extends Node3D

@onready var scene_container = $SceneContainer
@onready var ui_manager = $UIManager

@export var resonance_structures: PackedScene

func _ready() -> void:
	ui_manager.show_menu(UIManager.MenuState.MAIN_MENU)
	ui_manager.resonance_structures_pressed.connect(_on_resonance_structures_pressed)

func _on_resonance_structures_pressed():
	scene_container.add_child(resonance_structures.instantiate())
