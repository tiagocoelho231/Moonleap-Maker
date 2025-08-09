// Inherit the parent event
event_inherited();

if instance_exists(oLevelMaker)
and oLevelMaker.camera_current_interpolation == 1
and fade_in_time > 0 {
  fade_in_time -= 1;
}