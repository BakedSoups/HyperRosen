extends VBoxContainer

const MAIN = preload("res://scenes/main.tscn")

func _on_play_button_pressed():
	#get_tree().change_scene_to_packed(MAIN)
	visible = false
	get_parent().get_parent().get_node("Cameraman").stay = false
	get_parent().get_node("TextureRect").visible = false
	#GameData.player.get_node("Camera3D").current = true

func _on_quit_button_pressed():
	get_tree().quit()
	
