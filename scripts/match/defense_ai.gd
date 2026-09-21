class_name DefenseAI
extends Node

@export var marking_distance := 0.28
@export var separation_distance := 76.0

var marks: Dictionary = {}


func assign_marks(defenders: Array[MatchPlayer], attackers: Array[MatchPlayer], ball_owner: MatchPlayer) -> void:
	marks.clear()
	var available: Array[MatchPlayer] = []
	for attacker in attackers:
		available.append(attacker)
	var first_unassigned_defender := 0
	# The ball handler gets first assignment; remaining defenders take distinct nearest marks.
	if ball_owner != null and available.has(ball_owner) and not defenders.is_empty():
		marks[defenders[0].get_instance_id()] = ball_owner
		available.erase(ball_owner)
		first_unassigned_defender = 1
	for defender_index in range(first_unassigned_defender, defenders.size()):
		var defender: MatchPlayer = defenders[defender_index]
		if available.is_empty():
			break
		var best: MatchPlayer = available[0]
		var best_distance := defender.global_position.distance_to(best.global_position)
		for attacker in available:
			var distance := defender.global_position.distance_to(attacker.global_position)
			if distance < best_distance:
				best = attacker
				best_distance = distance
		marks[defender.get_instance_id()] = best
		available.erase(best)


func update_player(defender: MatchPlayer, defenders: Array[MatchPlayer], ball_owner: MatchPlayer, delta: float) -> void:
	var mark: MatchPlayer = marks.get(defender.get_instance_id()) as MatchPlayer
	if mark == null:
		return
	var desired := mark.global_position.lerp(MatchCourt.HOOP, marking_distance)
	if ball_owner != null and mark != ball_owner:
		var pass_lane_position := ball_owner.global_position.lerp(mark.global_position, 0.5)
		desired = desired.lerp(pass_lane_position, 0.22)
	var separation := Vector2.ZERO
	for other in defenders:
		if other == defender:
			continue
		var difference := defender.global_position - other.global_position
		var distance := difference.length()
		if distance > 0.01 and distance < separation_distance:
			separation += difference.normalized() * (separation_distance - distance)
	desired += separation * 0.85
	defender.move_towards(defender.global_position.direction_to(desired), delta, 0.74)
