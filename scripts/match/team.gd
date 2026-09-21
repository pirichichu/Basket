class_name MatchTeam
extends Node

var team_id := 0
var players: Array[MatchPlayer] = []


func offensive_spot(index: int) -> Vector2:
	var blue_spots: Array[Vector2] = [Vector2(530, 220), Vector2(480, 490), Vector2(740, 360)]
	var red_spots: Array[Vector2] = [Vector2(640, 180), Vector2(620, 535), Vector2(820, 360)]
	return (blue_spots if team_id == 0 else red_spots)[index]
