class_name PassingSystem
extends Node

func choose_receiver(passer: MatchPlayer, players: Array[MatchPlayer], intended_direction := Vector2.ZERO) -> MatchPlayer:
	if intended_direction.length() < 0.1:
		intended_direction = passer.global_position.direction_to(MatchCourt.HOOP)
	else:
		intended_direction = intended_direction.normalized()
	var best: MatchPlayer
	var best_score := -INF
	for candidate in players:
		if candidate == passer or candidate.team_id != passer.team_id:
			continue
		var distance := passer.global_position.distance_to(candidate.global_position)
		var candidate_direction := passer.global_position.direction_to(candidate.global_position)
		var alignment := intended_direction.dot(candidate_direction)
		var nearest_defender := nearest_defender_distance(candidate, players)
		# Direction carries most weight for human passes; openness still breaks ties.
		var score := alignment * 520.0 + nearest_defender * 1.4 - distance * 0.35
		if score > best_score:
			best_score = score
			best = candidate
	return best


func nearest_defender_distance(player: MatchPlayer, players: Array[MatchPlayer]) -> float:
	var nearest_distance := 230.0
	for other in players:
		if other.team_id != player.team_id:
			nearest_distance = minf(nearest_distance, player.global_position.distance_to(other.global_position))
	return nearest_distance
