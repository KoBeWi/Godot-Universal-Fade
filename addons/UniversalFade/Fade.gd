## Performs screen transition effect.
extends CanvasLayer
class_name Fade

## The project setting that determines pattern directory.
const PROJECT_SETTING = "addons/universal_fade/patterns_directory"
## The default directory for storing patterns.
const DEFAULT_PATTERN_DIRECTORY = "res://addons/UniversalFade/Patterns"

## Base directory where patterns are located. It's fetched from project setting and uses default if the setting does not exist.
static var pattern_directory: String

static func _static_init() -> void:
	if ProjectSettings.has_setting(PROJECT_SETTING):
		pattern_directory = ProjectSettings.get_setting(PROJECT_SETTING)
	else:
		pattern_directory = DEFAULT_PATTERN_DIRECTORY

## Emitted when the effect finishes.
signal finished

## Fades out the screen, so it becomes a single color. Use the parameters to customize it.
static func fade_out(time := 1.0, color := Color.BLACK, pattern := "", reverse := false, smooth := false) -> Fade:
	var fader := _create_fader(color, pattern, reverse, smooth)
	fader._fade(&"FadeOut", time)
	return fader

## Fades in the screen, so it's visible again. Use the parameters to customize it.
static func fade_in(time := 1.0, color := Color.BLACK, pattern := "", reverse := true, smooth := false) -> Fade:
	var fader := _create_fader(color, pattern, reverse, smooth)
	fader._fade(&"FadeIn", time)
	return fader

## Starts a crossfade effect. It will take snapshot of the current screen and freeze it (visually) until [method crossfade_execute] is called. Use the parameters to customize it.
static func crossfade_prepare(time := 1.0, pattern := "", reverse := false, smooth := false) -> void:
	_get_scene_tree_root().set_meta(&"__crossfade__", true)
	var fader := _create_fader(Color.WHITE, pattern, reverse, smooth)
	fader.set_meta(&"time", time)
	_get_scene_tree_root().set_meta(&"__crossfade__", fader)

## Executes the crossfade. [b]Before[/b] calling this method, make sure to call [method crossfade_prepare] [b]and[/b] e.g. change the scene. The screen will fade from the snapshotted image to the new scene.
static func crossfade_execute() -> Fade:
	assert(_get_scene_tree_root().has_meta(&"__crossfade__"), "No crossfade prepared. Use Fade.crossfade_prepare() first")
	var fader := _get_scene_tree_root().get_meta(&"__crossfade__") as Fade
	_get_scene_tree_root().remove_meta(&"__crossfade__")
	
	fader._fade(&"FadeIn", fader.get_meta(&"time"))
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
			var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
			image.fill(Color.WHITE)
			
			texture = ImageTexture.create_from_image(image)
			_get_scene_tree_root().set_meta(&"__1px_pattern__", texture)
	else:
		var pattern_path := pattern_directory.path_join(pattern) + ".png"
		assert(ResourceLoader.exists(pattern_path, "Texture2D"), "Pattern not found: '%s'. Make sure a PNG file with this name is located in '%s'." % [pattern, pattern_directory])
		texture = load(pattern_path)
	
	var fader = load("res://addons/UniversalFade/Fade.tscn").instantiate()
	fader._prepare_fade(color, texture, reverse, smooth, _get_scene_tree_root().get_meta(&"__crossfade__", false))
	_get_scene_tree_root().set_meta(&"__current_fade__", fader)
	_get_scene_tree_root().add_child(fader)
	return fader

static func _get_scene_tree_root() -> Viewport:
	return Engine.get_main_loop().root as Viewport

func _prepare_fade(color: Color, pattern: Texture2D, reverse: bool, smooth: bool, crossfade: bool):
	var mat := $TextureRect.material as ShaderMaterial
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"reverse", reverse)
	mat.set_shader_parameter(&"smooth_mode", smooth)
	
	if crossfade:
		mat.set_shader_parameter(&"use_custom_texture", true)
		mat.set_shader_parameter(&"custom_texture", pattern)
		$TextureRect.texture = ImageTexture.create_from_image(_get_scene_tree_root().get_texture().get_image())
	else:
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
