extends VBoxContainer

const MAIN = preload("res://scenes/main.tscn")

func _on_play_button_pressed():
	get_tree().change_scene_to_packed(MAIN)


func _on_quit_button_pressed():
	get_tree().quit()
	
