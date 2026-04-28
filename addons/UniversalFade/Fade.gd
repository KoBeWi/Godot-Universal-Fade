## Performs screen transition effect.
class_name Fade extends CanvasLayer

static var _fader_scene: PackedScene
static var _1px_pattern: Texture2D

static var _current_fade: Fade

var _crossfade_time: float = -1

## Emitted when the effect finishes.
signal finished

## Fades out the screen, so it becomes a single color over [param time] seconds. [param color] is the target color, [param reverse] reverses the pattern colors, while [param smooth] smoothens the pattern's alpha (instead of doing hard cut-off).
## [br][br][param pattern] is the pattern texture. If not specified, a simple fade effect will be performed, ignoring [param smooth] and [param reverse].
## [br][br][b]Note:[/b] Executing another fade effect before the previous one has finished will cancel the old fade.
static func fade_out(time := 1.0, color := Color.BLACK, pattern: Texture2D = null, reverse := false, smooth := false) -> Fade:
	assert(time > 0, "Fade time must be greater than 0.")
	
	var fader := _create_fader(color, pattern, reverse, smooth)
	fader._fade(time, true)
	return fader

## Fades in the screen, so it's visible again. The parameters are the same as in [method fade_out].
static func fade_in(time := 1.0, color := Color.BLACK, pattern: Texture2D = null, reverse := true, smooth := false) -> Fade:
	assert(time > 0, "Fade time must be greater than 0.")
	
	var fader := _create_fader(color, pattern, reverse, smooth)
	fader._fade(time, false)
	return fader

## Prepares a crossfade effect. It will take snapshot of the current screen and freeze it (visually) until [method crossfade_execute] is called. The parameters are the same as in [method fade_out].
static func crossfade_prepare(time := 1.0, pattern: Texture2D = null, reverse := false, smooth := false) -> void:
	assert(time > 0, "Fade time must be greater than 0.")
	
	var fader := _create_fader(Color.WHITE, pattern, reverse, smooth, true)
	fader._crossfade_time = time

## Executes the crossfade. [b]Before[/b] calling this method, make sure to call [method crossfade_prepare] [b]and[/b] e.g. change the scene. The screen will fade from the snapshotted image to the new scene, using the prepared parameters.
static func crossfade_execute() -> Fade:
	assert(is_instance_valid(_current_fade) and _current_fade._crossfade_time > 0, "No crossfade prepared. Use Fade.crossfade_prepare() first.")
	
	_current_fade._fade(_current_fade._crossfade_time, false)
	return _current_fade

static func _create_fader(color: Color, pattern: Texture2D, reverse: bool, smooth: bool, crossfade := false) -> Fade:
	if is_instance_valid(_current_fade):
		_current_fade.queue_free()
	
	var texture: Texture2D
	if pattern:
		texture = pattern
	else:
		smooth = true
		reverse = false
		
		if not _1px_pattern:
			var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
			image.fill(Color.WHITE)
			_1px_pattern = ImageTexture.create_from_image(image)
		
		texture = _1px_pattern
	
	if not _fader_scene:
		_fader_scene = load("uid://dh8yln8lji7v2")
	
	_current_fade = _fader_scene.instantiate()
	_current_fade._prepare_fade(color, texture, reverse, smooth, crossfade)
	_get_scene_tree_root().add_child(_current_fade)
	return _current_fade

static func _get_scene_tree_root() -> Node:
	return Engine.get_main_loop().root as Node

func _prepare_fade(color: Color, pattern: Texture2D, reverse: bool, smooth: bool, crossfade: bool):
	var texture_rect: TextureRect = $TextureRect
	
	var mat: ShaderMaterial = texture_rect.material
	mat.set_shader_parameter(&"color", color)
	mat.set_shader_parameter(&"reverse", reverse)
	mat.set_shader_parameter(&"smooth_mode", smooth)
	
	if crossfade:
		mat.set_shader_parameter(&"use_custom_texture", true)
		mat.set_shader_parameter(&"custom_texture", pattern)
		texture_rect.texture = ImageTexture.create_from_image(_get_scene_tree_root().get_texture().get_image())
	else:
		texture_rect.texture = pattern

func _fade(time: float, out: bool):
	var target := 1.0 if out else 0.0
	
	var tween := create_tween()
	tween.tween_property($TextureRect.material, ^"shader_parameter/opacity", target, time).from(1.0 - target)
	tween.tween_callback(_fade_finished.bind(out))

func _fade_finished(out: bool) -> void:
	finished.emit()
	
	if not out:
		queue_free()
