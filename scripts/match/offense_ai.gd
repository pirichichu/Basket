class_name OffenseAI
extends Node

enum Action { DRIBBLE, PASS, SHOOT, PROTECT }

@export var open_shot_distance := 100.0
@export var close_shot_distance := 185.0
@export var shooting_range := 410.0


func update_player(player: MatchPlayer, ball_owner: MatchPlayer, defenders: Array[MatchPlayer], delta: float) -> void:
	if player == ball_owner:
		var drive_direction := _dribble_direction(player, defenders)
		player.move_towards(drive_direction, delta, 0.76)
		return
	var desired: Vector2 = _spacing_target(player, ball_owner)
	player.move_towards(player.global_position.direction_to(desired), delta, 0.78)


func decide(ball_owner: MatchPlayer, players: Array[MatchPlayer], defenders: Array[MatchPlayer], passing: PassingSystem) -> Dictionary:
	var result: Dictionary = {"action": Action.DRIBBLE, "receiver": null, "timing": 0.0}
	var hoop_distance := ball_owner.global_position.distance_to(MatchCourt.HOOP)
	var pressure := _nearest_defender_distance(ball_owner, defenders)
	var receiver := passing.choose_receiver(ball_owner, players, ball_owner.global_position.direction_to(MatchCourt.HOOP))
	var receiver_advantage := 0.0
	if receiver != null:
		var receiver_space := passing.nearest_defender_distance(receiver, players)
		receiver_advantage = receiver_space - pressure + _position_quality(receiver)
	if hoop_distance < close_shot_distance and pressure > 42.0:
		result["action"] = Action.SHOOT
		result["timing"] = _ai_timing(ball_owner, 0.12)
	elif hoop_distance < shooting_range and pressure > open_shot_distance and randf() < 0.72:
		result["action"] = Action.SHOOT
		result["timing"] = _ai_timing(ball_owner, 0.22)
	elif receiver != null and receiver_advantage > 85.0 and randf() < 0.72:
		result["action"] = Action.PASS
		result["receiver"] = receiver
	elif pressure < 58.0 and receiver != null:
		result["action"] = Action.PASS
		result["receiver"] = receiver
	elif pressure < 52.0:
		result["action"] = Action.PROTECT
	return result


func _dribble_direction(player: MatchPlayer, defenders: Array[MatchPlayer]) -> Vector2:
	var toward_hoop := player.global_position.direction_to(MatchCourt.HOOP)
	var nearest := _nearest_defender(player, defenders)
	if nearest == null:
		return toward_hoop
	var defender_offset := nearest.global_position - player.global_position
	var side_step := Vector2(-toward_hoop.y, toward_hoop.x)
	var phase := sin(Time.get_ticks_msec() * 0.004 + player.number * 2.3)
	if defender_offset.length() < 120.0:
		var side_sign := 1.0 if defender_offset.dot(side_step) < 0.0 else -1.0
		return (toward_hoop * 0.45 + side_step * side_sign * 0.90).normalized()
	return (toward_hoop + side_step * phase * 0.32).normalized()


func _spacing_target(player: MatchPlayer, ball_owner: MatchPlayer) -> Vector2:
	var left_corner := Vector2(270, 565)
	var right_wing := Vector2(985, 485)
	var cut_lane := Vector2(790, 300)
	if ball_owner != null and ball_owner.global_position.y < 405 and player.number == 3:
		return cut_lane
	if player.number % 2 == 0:
		return left_corner
	return right_wing


func _nearest_defender(player: MatchPlayer, defenders: Array[MatchPlayer]) -> MatchPlayer:
	var closest: MatchPlayer
	var closest_distance := INF
	for defender in defenders:
		var distance := player.global_position.distance_to(defender.global_position)
		if distance < closest_distance:
			closest = defender
			closest_distance = distance
	return closest


func _nearest_defender_distance(player: MatchPlayer, defenders: Array[MatchPlayer]) -> float:
	var nearest := _nearest_defender(player, defenders)
	return player.global_position.distance_to(nearest.global_position) if nearest != null else 999.0


func _position_quality(player: MatchPlayer) -> float:
	var hoop_distance := player.global_position.distance_to(MatchCourt.HOOP)
	return clampf(260.0 - hoop_distance, -90.0, 130.0)


func _ai_timing(player: MatchPlayer, error_range: float) -> float:
	# Better shooters land closer to the green internally, without rendering a meter.
	var error := (1.0 - player.shooting_rating) * error_range
	var result := 1.0 - absf(randf_range(-error, error)) * 2.8
	return 1.0 if randf() < player.shooting_rating * 0.22 else clampf(result, 0.05, 0.84)
