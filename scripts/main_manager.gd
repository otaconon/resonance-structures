extends Node

@onready var level_container: Node = $LevelContainer
@onready var ui_manager: UIManager = $UiManager

var current_level: Node = null

func _ready() -> void:
	ui_manager.show_menu(UIManager.MenuState.MAIN_MENU)