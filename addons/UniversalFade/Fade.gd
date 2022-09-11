extends CanvasLayer
class_name Fade

## Emitted when the effect finishes.
signal finished

## Fades out the screen, so it becomes a single color.
static func fade_out(time := 1.0, color := Color.BLACK, pattern := "", reverse := false, smooth := false) -> Fade:
	var fader := _create_fader(color, pattern, reverse, smooth)
	fader._fade(&"FadeOut", time)
	return fader

## Fades in the screen, so it's visible again.
static func fade_in(time := 1.0, color := Color.BLACK, pattern := "", reverse := true, smooth := false) -> Fade:
	var fader := _create_fader(color, pattern, reverse, smooth)
	fader._fade(&"FadeIn", time)
	return fader

static func _create_fader(color: Color, pattern: String, reverse: bool, smooth: bool) -> Fade:
	if _get_scene_tree_root().has_meta(&"__current_fade__"):
		var old = _get_scene_tree_root().get_meta(&"__current_fade__")
		if is_instance_valid(old):
			old.queue_free()
	
	var texture: Texture2D
	if pattern.is_empty():
		smooth = true
		reverse = false
		
		if _get_scene_tree_root().has_meta(&"__1px_pattern__"):
			texture = _get_scene_tree_root().get_meta(&"__1px_pattern__")
		else:
			var image := Image.new()
			image.create(1, 1, false, Image.FORMAT_RGBA8)
			image.fill(Color.WHITE)
			
			texture = ImageTexture.create_from_image(image)
			_get_scene_tree_root().set_meta(&"__1px_pattern__", texture)
	else:
		var pattern_path := "res://addons/UniversalFade/Pattern%s.png" % pattern
		assert(ResourceLoader.exists(pattern_path, "Texture2D"), "Invalid pattern name.")
		texture = load(pattern_path)
	
	var fader = load("res://addons/UniversalFade/Fade.tscn").instantiate()
	fader._prepare_fade(color, texture, reverse, smooth)
	_get_scene_tree_root().set_meta(&"__current_fade__", fader)
	_get_scene_tree_root().add_child(fader)
	return fader

static func _get_scene_tree_root() -> Node:
	return Engine.get_main_loop().root as Node

func _prepare_fade(color: Color, pattern: Texture2D, reverse: bool, smooth: bool):
	var mat := $TextureRect.material as ShaderMaterial
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"reverse", reverse)
	mat.set_shader_parameter(&"smooth_mode", smooth)
	$TextureRect.texture = pattern

func _fade(animation: StringName, time: float):
	assert(time > 0, "Time must be greater than 0.")
	var player := $AnimationPlayer as AnimationPlayer
	player.play(animation, -1, 1.0 / time)
	player.advance(0)

func _fade_finished(anim_name: StringName) -> void:
	finished.emit()
	
	if anim_name == &"FadeIn":
		queue_free()
