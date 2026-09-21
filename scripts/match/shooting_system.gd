class_name ShootingSystem
extends Node

@export var ideal_power := 0.58
@export var minimum_accuracy := 0.08
@export var maximum_range := 455.0
@export var green_make_chance := 0.98


func accuracy_for(shooter: MatchPlayer, power: float) -> float:
	var distance_factor := 1.0 - clampf(shooter.global_position.distance_to(MatchCourt.HOOP) / maximum_range, 0.0, 0.7)
	var power_factor := 1.0 - absf(power - ideal_power) * 1.45
	return clampf(minimum_accuracy, 0.9 * distance_factor * power_factor, 0.92)


func accuracy_for_timing(shooter: MatchPlayer, timing_quality: float) -> float:
	# Green releases are intentionally dominant; ratings affect the window and near-greens.
	if timing_quality >= 0.999:
		return green_make_chance
	var distance_factor := 1.0 - clampf(shooter.global_position.distance_to(MatchCourt.HOOP) / maximum_range, 0.0, 0.7)
	var rating_factor := lerpf(0.76, 1.24, shooter.shooting_rating)
	var timing_factor := 0.10 + timing_quality * 0.60
	return clampf(minimum_accuracy, distance_factor * timing_factor * rating_factor, 0.82)
