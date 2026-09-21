class_name PossessionSystem
extends Node

var ball_owner: MatchPlayer
var team_in_possession := 0


func set_ball_owner(new_owner: MatchPlayer) -> void:
	if ball_owner != null:
		ball_owner.has_ball = false
		ball_owner.queue_redraw()
	ball_owner = new_owner
	if ball_owner != null:
		team_in_possession = ball_owner.team_id
		ball_owner.has_ball = true
		ball_owner.queue_redraw()


func clear() -> void:
	if ball_owner != null:
		ball_owner.has_ball = false
		ball_owner.queue_redraw()
	ball_owner = null
