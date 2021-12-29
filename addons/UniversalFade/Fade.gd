extends CanvasLayer
class_name Fade

signal finished

static func fade_out(time: float, color := Color.black, pattern := "", reverse := false, smooth := false):
	var fader = _create_fader(color, pattern, reverse, smooth)
	fader._fade("FadeOut", time)
	return fader

static func fade_in(time: float, color := Color.black, pattern := "", reverse := false, smooth := false):
	var fader = _create_fader(color, pattern, reverse, smooth)
	fader._fade("FadeIn", time)
	return fader

static func _create_fader(color: Color, pattern: String, reverse: bool, smooth: bool):
	if _get_scene_tree_root().has_meta("__current_fade__"):
		var old = _get_scene_tree_root().get_meta("__current_fade__")
		if is_instance_valid(old):
			old.queue_free()
	
	var texture: Texture
	if pattern.empty():
		smooth = true
		reverse = false
		
		if _get_scene_tree_root().has_meta("__1px_pattern__"):
			texture = _get_scene_tree_root().get_meta("__1px_pattern__")
		else:
			var image := Image.new()
			image.create(1, 1, false, Image.FORMAT_RGBA8)
			image.fill(Color.black)
			
			texture = ImageTexture.new()
			texture.create_from_image(image)
			_get_scene_tree_root().set_meta("__1px_pattern__", texture)
	else:
		var pattern_path := str("res://addons/UniversalFade/Pattern", pattern, ".png")
		assert(ResourceLoader.exists(pattern_path, "Texture"), "Invalid pattern name.")
		texture = load(pattern_path)
	
	var fader = load("res://addons/UniversalFade/Fade.tscn").instance()
	fader._prepare_fade(color, texture, reverse, smooth)
	_get_scene_tree_root().set_meta("__current_fade__", fader)
	_get_scene_tree_root().add_child(fader)
	return fader

static func _get_scene_tree_root() -> Node:
	return Engine.get_main_loop().root as Node

func _prepare_fade(color: Color, pattern: Texture, reverse: bool, smooth: bool):
	var rect := $TextureRect as TextureRect
	rect.material.set_shader_param("color", color)
	rect.material.set_shader_param("reverse", reverse)
	rect.material.set_shader_param("smooth_mode", smooth)
	rect.texture = pattern

func _fade(animation: String, time: float):
	assert(time > 0, "Time must be greater than 0.")
	$AnimationPlayer.play(animation, -1, 1.0 / time)

func _fade_finished(anim_name: String) -> void:
	emit_signal("finished")
	
	if anim_name == "FadeIn":
		queue_free()
