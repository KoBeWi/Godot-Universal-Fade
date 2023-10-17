@tool
extends RefCounted

static func _static_init() -> void:
	assert(Engine.is_editor_hint())
	
	if not ProjectSettings.has_setting(Fade.PROJECT_SETTING):
		ProjectSettings.set_setting(Fade.PROJECT_SETTING, Fade.DEFAULT_PATTERN_DIRECTORY)
		ProjectSettings.save()
