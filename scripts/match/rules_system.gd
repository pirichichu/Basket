class_name RulesSystem
extends Node

signal basket_scored(team_id: int)

var scores := [0, 0]


func award_basket(team_id: int) -> void:
	scores[team_id] += 1
	basket_scored.emit(team_id)

