class_name UIManager
extends CanvasLayer

@onready var main_menu = $MainMenu
@onready var options_menu = $OptionsMenu

enum MenuState {
	MAIN_MENU,
	OPTIONS_MENU,
	NONE
}

func show_menu(menu_state: MenuState) -> void:
	main_menu.visible = menu_state == MenuState.MAIN_MENU
	options_menu.visible = menu_state == MenuState.OPTIONS_MENU

func _ready() -> void:
	main_menu.options_menu_requested.connect(_on_options_menu_requested)
	main_menu.quit_requested.connect(_on_quit_requested)

	options_menu.back_requested.connect(_on_start_menu_requested)

func _on_start_menu_requested() -> void:
	show_menu(MenuState.MAIN_MENU)

func _on_options_menu_requested() -> void:
	show_menu(MenuState.OPTIONS_MENU)

func _on_quit_requested() -> void:
	get_tree().quit()
