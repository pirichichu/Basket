class_name MatchAIController
extends Node

@export var think_speed := 0.9


func update_player(player: MatchPlayer, all_players: Array[MatchPlayer], ball_owner: MatchPlayer, possession_team: int, delta: float) -> void:
	var desired := player.global_position
	if player == ball_owner:
		# Drive gently toward the hoop but keep an arcade-friendly offset.
		desired = MatchCourt.HOOP + Vector2(-115, sin(Time.get_ticks_msec() * 0.0015 + player.number) * 115)
	elif player.team_id == possession_team:
		desired = _spacing_position(player, ball_owner)
	else:
		var mark := _closest_opponent(player, all_players)
		if ball_owner != null and ball_owner.team_id != player.team_id:
			mark = ball_owner
		if mark != null:
			# Defend from the hoop side.
			desired = mark.global_position.lerp(MatchCourt.HOOP, 0.28)
	var direction := player.global_position.direction_to(desired)
	player.move_towards(direction, delta, 0.74)


func _spacing_position(player: MatchPlayer, ball_owner: MatchPlayer) -> Vector2:
	var offsets: Array[Vector2] = [Vector2(-150, -145), Vector2(-170, 150), Vector2(-40, 205)]
	var offset: Vector2 = offsets[player.number % offsets.size()]
	if ball_owner != null:
		return ball_owner.global_position + offset
	return Vector2(600, 360)


func _closest_opponent(player: MatchPlayer, players: Array[MatchPlayer]) -> MatchPlayer:
	var closest: MatchPlayer
	var closest_distance := INF
	for other in players:
		if other.team_id == player.team_id:
			continue
		var distance := player.global_position.distance_to(other.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = other
	return closest
