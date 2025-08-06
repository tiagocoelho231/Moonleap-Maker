scr_inputget();
// You can write your code in this editor

drawx = random_range(-holding, holding);
drawy = random_range(-holding, holding);

if cleared_level {
	drawx = 0;
	drawy = 0;
}

drawtarget = 0;

//lerp play button position to be visible in play state
if image_index == LEVEL_BUTTON_IMAGE_INDEX.TEST_LEVEL { 
    //editor is opened
	if level_maker_is_editing() {
		x = lerp(x,start_pos_x,.2);
		y = lerp(y,start_pos_y,.2);
		
		image_xscale = lerp(image_xscale,1,.2);
		image_yscale = image_xscale;
	} else {
		x = lerp(x,(32-small_size)/2,.2);
		y = lerp(y,room_height-16-small_size/2,.2);

		image_xscale = lerp(image_xscale,small_size/32,.2);
		image_yscale = image_xscale;
	}
} else if not level_maker_is_editing() 
or instance_exists_any([oPauseMenu, oMakerWarning]) {
  exit;
}

var stext = "";
switch (image_index) {
    case LEVEL_BUTTON_IMAGE_INDEX.MOVE_OBJECT_GROUP_UP:  hover_text = LANG.maker_change_up;			break;
    case LEVEL_BUTTON_IMAGE_INDEX.MOVE_OBJECT_GROUP_DOWN:  hover_text = LANG.maker_change_down;		break;
    case LEVEL_BUTTON_IMAGE_INDEX.CREATOR_MENU:  hover_text = LANG.maker_menu;				break;
    case LEVEL_BUTTON_IMAGE_INDEX.SAVE_LEVEL:  hover_text = LANG.maker_savemenu;			break;
    case LEVEL_BUTTON_IMAGE_INDEX.LOAD_LEVEL:  hover_text = LANG.maker_load;				break;
    case LEVEL_BUTTON_IMAGE_INDEX.TEST_LEVEL:  hover_text = LANG.maker_play;				break;
    case LEVEL_BUTTON_IMAGE_INDEX.HELP:  hover_text = LANG.maker_help;				break;
    case LEVEL_BUTTON_IMAGE_INDEX.CHANGE_STYLE: 
        switch (oLevelMaker.selected_style) {
            case LEVEL_STYLE.GRASS:		stext = LANG.maker_grassstyle;		break;
            case LEVEL_STYLE.CLOUDS:	stext = LANG.maker_cloudstyle;		break;
            case LEVEL_STYLE.FLOWERS:	stext = LANG.maker_flowerstyle;		break;
            case LEVEL_STYLE.SPACE:		stext = LANG.maker_spacestyle;		break;
            case LEVEL_STYLE.DUNGEON:	stext = LANG.maker_dungeonstyle;	break;
        }
        hover_text = $"{LANG.maker_change_level_style}\n{stext}";
        break;
    case LEVEL_BUTTON_IMAGE_INDEX.ERASER:  hover_text = LANG.maker_eraser; break;
    case LEVEL_BUTTON_IMAGE_INDEX.CLEAR_LEVEL: hover_text = LANG.maker_erase_level; break;
    case LEVEL_BUTTON_IMAGE_INDEX.CHANGE_LAYER: hover_text = $"{LANG.maker_change_layer}\n{level_maker_get_layer_hover_text()}"; break;
}

var is_mouse_left_pressing = mouse_check_button_pressed(mb_left);
var is_mouse_hover = collision_point(global.level_maker_mouse_x,global.level_maker_mouse_y,self,false,false);
if is_mouse_hover and mouse_check_button(mb_left) { 
    drawplus = 2;
} else {
	holding = 0; 
	cleared_level = false;
	is_mouse_left_pressing = false;
}
// =============================
// ALL BUTTON FUNCTIONS
// =============================

// None
// if image_index == LEVEL_BUTTON_IMAGE_INDEX.NONE and is_mouse_left_pressing {}

if image_index == LEVEL_BUTTON_IMAGE_INDEX.MOVE_OBJECT_GROUP_UP and (is_mouse_left_pressing or key_down or mouse_wheel_up())
{
	with(oLevelMaker)
	{
		var _pages_length = current_layer == LEVEL_CURRENT_LAYER.OBJECTS ? array_length(obj) - 1 : array_length(tiles) - 1;
		
		audio_play_sfx(snd_morcego_02, false, -20, 13);
		
		item_preview_offset_y = -4;
	    selected_object_type -= 1;
		repeat(_pages_length) {
			if selected_object_type < 0 then
				selected_object_type = _pages_length;
			if selected_object == noone then
				selected_object_type -= 1;
		}
		
		oButtonMakerObj.drawplus = -1;

        with(oLevelMaker) {
            image_xscale = 1;
            image_yscale = 1;
            image_angle = 0;
            update_current_item();
        }
	}
}

if image_index == LEVEL_BUTTON_IMAGE_INDEX.MOVE_OBJECT_GROUP_DOWN and (is_mouse_left_pressing or key_up or mouse_wheel_down()) {
	with(oLevelMaker) {
		var _pages_length = current_layer == LEVEL_CURRENT_LAYER.OBJECTS ? array_length(obj) - 1 : array_length(tiles) - 1;
		
		audio_play_sfx(snd_morcego_02, false, -20, 13);
		
		item_preview_offset_y = 4;
	    selected_object_type += 1;
		
		repeat(list_positions_length - 1) {
			if selected_object_type > _pages_length then
				selected_object_type = 0;
			if selected_object = noone then 
				selected_object_position += 1;
		}
		
		oButtonMakerObj.drawplus = 1

		with(oLevelMaker) {
            image_xscale = 1;
            image_yscale = 1;
            image_angle = 0;
            update_current_item();
        }
	}
}

if image_index == LEVEL_BUTTON_IMAGE_INDEX.CREATOR_MENU and is_mouse_left_pressing {
	play_sound_on_press();
	instance_create_layer(-16, -16, "Instances_2", oPauseMenu);
}

if image_index == LEVEL_BUTTON_IMAGE_INDEX.SAVE_LEVEL and (is_mouse_left_pressing or (keyboard_check(vk_lcontrol) and keyboard_check_pressed(ord("S")))) {
	play_sound_on_press();
	d_levelName = get_save_filename("*.moonlevel", "Nome do nivel - Nome do autor do nivel");
	if (d_levelName != "") then level_maker_save(d_levelName);
}

if image_index == LEVEL_BUTTON_IMAGE_INDEX.LOAD_LEVEL and is_mouse_left_pressing {
	play_sound_on_press();
	
	d_loadLevel = get_open_filename("*.moonlevel", "Meu nivel");
	if (d_loadLevel != "") then level_maker_load(d_loadLevel);
	
	with (oLevelMaker) {
		item_place_disable_timer.reset();
	}
}

if image_index == LEVEL_BUTTON_IMAGE_INDEX.TEST_LEVEL and (is_mouse_left_pressing or keyboard_check_pressed(vk_f5)) {
	play_sound_on_press();
	
	with(oLevelMaker) {
		if level_maker_is_editing() {
			start_level();
		} else {
			oLevelMaker.item_place_disable_timer.reset();
			oLevelMaker.end_level_and_return_to_editor();
		}
	}
}

if image_index == LEVEL_BUTTON_IMAGE_INDEX.HELP and is_mouse_left_pressing {
	play_sound_on_press();
	
	show_message_async(LANG.maker_help_text)
}

if image_index == LEVEL_BUTTON_IMAGE_INDEX.CHANGE_STYLE and is_mouse_left_pressing {
	play_sound_on_press();
	
  if instance_number(oMakerEditorTileDraft) > 0 {
    var _warning = instance_create_layer(0, 0, "Instances_2", oMakerWarning);
    
    _warning.text_warning = LANG.maker_warning_change_style;
    _warning.action_on_confirm = change_style;
  } else {
    change_style();
  }
}

if image_index == LEVEL_BUTTON_IMAGE_INDEX.ERASER and is_mouse_left_pressing {
	audio_play_sfx(sndUiChange,false,-18.3,1)
	oLevelMaker.cursor = LEVEL_CURSOR_TYPE.ERASER;
}

if image_index == LEVEL_BUTTON_IMAGE_INDEX.CLEAR_LEVEL {
	if mouse_check_button(mb_left) {
		if not cleared_level {
			holding = min(holding + 0.05, 4);
		
			if holding == 4 {
				cleared_level = true;
				audio_play_sfx(sfx_luano_death_pause_01, false, -8.79, 5);
				with(oLevelMaker) {
					clear_level();
					set_sample_level();
				}
			
			}
		}
	} else {
		holding = 0;
		cleared_level = false;
	}
}

if image_index == LEVEL_BUTTON_IMAGE_INDEX.CHANGE_LAYER and is_mouse_left_pressing {
	play_sound_on_press();
	
	with(oLevelMaker) {
		selected_object = undefined;
		selected_object_type = 0;
		selected_object_position = 0;
		
		current_layer += 1;
		if current_layer > 3 then
			current_layer = LEVEL_CURRENT_LAYER.FOREGROUND;

    update_current_item();
	}
}