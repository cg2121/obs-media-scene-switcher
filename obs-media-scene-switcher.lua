obs = obslua

source_name = ""
scene_name = ""

function media_end(cd)
	local source = obs.obs_get_source_by_name(scene_name)
	obs.obs_source_release(source)
	
	obs.obs_frontend_set_current_scene(source)
end

function script_properties()
	local props = obs.obs_properties_create()

	local prop_sources = obs.obs_properties_add_list(props, "source", "Media Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources = obs.obs_enum_sources()
	if sources ~= nil then
		for _, source in ipairs(sources) do
			local source_id = obs.obs_source_get_id(source)
			if source_id == "vlc_source" or source_id == "ffmpeg_source"  then
				local name = obs.obs_source_get_name(source)
				obs.obs_property_list_add_string(prop_sources, name, name)
			end
		end
	end
	obs.source_list_release(sources)

	local prop_scenes = obs.obs_properties_add_list(props, "scene", "Switch to scene", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local scenes = obs.obs_frontend_get_scenes()
	if scenes ~= nil then
		for _, scene in ipairs(scenes) do
			local name = obs.obs_source_get_name(scene);
			obs.obs_property_list_add_string(prop_scenes, name, name)
		end
	end
	obs.source_list_release(scenes)

	return props
end

function script_description()
	return "Switches to scene when media is ended."
end

function connect_signals()
	local source = obs.obs_get_source_by_name(source_name)
	obs.obs_source_release(source)
	
	obs.signal_handler_disconnect(obs.obs_source_get_signal_handler(source), "media_ended", media_end)
	
	if source ~= nil then
		obs.signal_handler_connect(obs.obs_source_get_signal_handler(source), "media_ended", media_end)
	end
end

function script_update(settings)
	source_name = obs.obs_data_get_string(settings, "source")
	scene_name = obs.obs_data_get_string(settings, "scene")

	connect_signals()
end

function script_load(settings)
	script_update(settings)
end
