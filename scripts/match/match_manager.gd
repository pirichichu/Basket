class_name MatchManager
extends Node2D

const PLAYER_SCRIPT := preload("res://scripts/match/player.gd")
const BALL_SCRIPT := preload("res://scripts/match/ball.gd")
const POSSESSION_SCRIPT := preload("res://scripts/match/possession_system.gd")
const PASSING_SCRIPT := preload("res://scripts/match/passing_system.gd")
const SHOOTING_SCRIPT := preload("res://scripts/match/shooting_system.gd")
const RULES_SCRIPT := preload("res://scripts/match/rules_system.gd")
const OFFENSE_AI_SCRIPT := preload("res://scripts/match/offense_ai.gd")
const DEFENSE_AI_SCRIPT := preload("res://scripts/match/defense_ai.gd")
const TEAM_SCRIPT := preload("res://scripts/match/team.gd")

@onready var hud: MatchHud = $HUDLayer/Hud
@onready var player_controller: PlayerController = $PlayerController
@onready var camera: MatchFollowCamera = $Camera2D

var players: Array[MatchPlayer] = []
var human_player: MatchPlayer
var ball: MatchBall
var possession: PossessionSystem
var passing: PassingSystem
var shooting: ShootingSystem
var rules: RulesSystem
var offense_ai: OffenseAI
var defense_ai: DefenseAI
var shot_timing: ShotTiming
var teams: Array[MatchTeam] = []
var ai_action_cooldown := 0.45
var reset_cooldown := 0.0


func _ready() -> void:
	_create_systems()
	_create_players()
	_connect_signals()
	_start_possession(0, human_player)
	camera.target = human_player


func _create_systems() -> void:
	possession = POSSESSION_SCRIPT.new()
	passing = PASSING_SCRIPT.new()
	shooting = SHOOTING_SCRIPT.new()
	rules = RULES_SCRIPT.new()
	offense_ai = OFFENSE_AI_SCRIPT.new()
	defense_ai = DEFENSE_AI_SCRIPT.new()
	add_child(possession)
	add_child(passing)
	add_child(shooting)
	add_child(rules)
	add_child(offense_ai)
	add_child(defense_ai)
	ball = BALL_SCRIPT.new()
	$Entities.add_child(ball)
	shot_timing = ShotTiming.new()
	$Entities.add_child(shot_timing)


func _create_players() -> void:
	for team_id in 2:
		var team: MatchTeam = TEAM_SCRIPT.new()
		team.team_id = team_id
		teams.append(team)
		add_child(team)
		for index in 3:
			var player: MatchPlayer = PLAYER_SCRIPT.new()
			player.team_id = team_id
			player.number = index + 1
			player.shooting_rating = 0.56 + index * 0.10
			player.player_name = ("Azul " if team_id == 0 else "Rojo ") + str(index + 1)
			player.tint = Color("42bff5") if team_id == 0 else Color("ef5864")
			player.global_position = team.offensive_spot(index)
			if team_id == 0 and index == 0:
				player.is_human = true
				player.player_name = "PlayerControlled"
				player.shooting_rating = 0.72
				human_player = player
			$Entities.add_child(player)
			players.append(player)
			team.players.append(player)


func _connect_signals() -> void:
	hud.joystick_changed.connect(func(direction: Vector2) -> void: player_controller.virtual_direction = direction)
	hud.pass_pressed.connect(_human_pass)
	hud.shoot_started.connect(_start_human_shot_timing)
	hud.shoot_released.connect(_human_shoot)
	hud.exit_pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/lobby/jugador.tscn"))
	ball.arrived.connect(_receive_pass)
	ball.intercepted.connect(_receive_interception)
	ball.scored.connect(_on_ball_scored)
	rules.basket_scored.connect(_on_basket_scored)


func _physics_process(delta: float) -> void:
	if reset_cooldown > 0.0:
		reset_cooldown -= delta
		return
	# PlayerControlled is never swapped, including when the other team has the ball.
	human_player.move_towards(player_controller.movement_direction(), delta)
	var offense_players: Array[MatchPlayer] = _players_for_team(possession.team_in_possession)
	var defense_players: Array[MatchPlayer] = _players_for_team(1 - possession.team_in_possession)
	defense_ai.assign_marks(defense_players, offense_players, possession.ball_owner)
	for player in players:
		if player == human_player:
			continue
		if player.team_id == possession.team_in_possession:
			offense_ai.update_player(player, possession.ball_owner, defense_players, delta)
		else:
			defense_ai.update_player(player, defense_players, possession.ball_owner, delta)
	_update_loose_ball()
	ai_action_cooldown -= delta
	if ai_action_cooldown <= 0.0:
		ai_action_cooldown = randf_range(0.38, 0.72)
		_take_ai_action()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_human_pass()
	if event.is_action_pressed("ui_select"):
		_human_shoot(0.58)


func _human_pass() -> void:
	if reset_cooldown > 0.0 or possession.ball_owner != human_player:
		return
	var pass_direction := player_controller.movement_direction()
	var receiver := passing.choose_receiver(human_player, players, pass_direction)
	if receiver != null:
		possession.clear()
		ball.pass_to(human_player, receiver, _players_for_team(1 - human_player.team_id))
		hud.show_message("Pase a %s" % receiver.player_name)


func _start_human_shot_timing() -> void:
	if reset_cooldown <= 0.0 and possession.ball_owner == human_player:
		shot_timing.begin(human_player)


func _human_shoot(_button_hold_power: float) -> void:
	if reset_cooldown > 0.0 or possession.ball_owner != human_player:
		shot_timing.cancel()
		return
	var timing_quality := shot_timing.release()
	var accuracy := shooting.accuracy_for_timing(human_player, timing_quality)
	possession.clear()
	ball.shoot_from(human_player, 0.62, accuracy)
	hud.show_message("%s" % ("¡Timing verde!" if shot_timing.last_release_was_green else "Timing %d%%" % int(timing_quality * 100.0)))


func _receive_pass(receiver: MatchPlayer) -> void:
	possession.set_ball_owner(receiver)
	ball.hold_by(receiver)


func _receive_interception(defender: MatchPlayer) -> void:
	possession.set_ball_owner(defender)
	ball.hold_by(defender)
	hud.show_message("¡Intercepción de %s!" % defender.player_name)


func _update_loose_ball() -> void:
	if ball.state != MatchBall.State.LOOSE:
		return
	var closest: MatchPlayer
	var distance := 45.0
	for player in players:
		var candidate_distance := player.global_position.distance_to(ball.global_position)
		if candidate_distance < distance:
			distance = candidate_distance
			closest = player
	if closest != null:
		_start_possession(closest.team_id, closest)
		hud.show_message("Balón recuperado por %s" % closest.player_name)


func _take_ai_action() -> void:
	var ball_owner := possession.ball_owner
	if ball_owner == null or ball_owner == human_player:
		return
	var defenders: Array[MatchPlayer] = _players_for_team(1 - ball_owner.team_id)
	var decision := offense_ai.decide(ball_owner, players, defenders, passing)
	var action: int = decision["action"]
	if action == OffenseAI.Action.SHOOT:
		var timing_quality: float = decision["timing"]
		var accuracy := shooting.accuracy_for_timing(ball_owner, timing_quality)
		possession.clear()
		ball.shoot_from(ball_owner, 0.62, accuracy)
	elif action == OffenseAI.Action.PASS:
		var receiver: MatchPlayer = decision["receiver"] as MatchPlayer
		if receiver != null:
			possession.clear()
			ball.pass_to(ball_owner, receiver, defenders)


func _on_ball_scored(team_id: int) -> void:
	rules.award_basket(team_id)


func _on_basket_scored(team_id: int) -> void:
	hud.set_score(rules.scores[0], rules.scores[1])
	hud.show_message("¡CANASTA %s!" % ("AZUL" if team_id == 0 else "ROJO"), 2.0)
	reset_cooldown = 1.5
	possession.clear()
	ball.state = MatchBall.State.LOOSE
	ball.velocity = Vector2.ZERO
	ball.global_position = MatchCourt.HOOP
	# The scored-on side receives a clear new possession.
	_reposition_for_check(1 - team_id)


func _reposition_for_check(receiving_team: int) -> void:
	for team_id in 2:
		for index in teams[team_id].players.size():
			var player := teams[team_id].players[index]
			player.global_position = teams[team_id].offensive_spot(index)
			if team_id != receiving_team:
				player.global_position = player.global_position.lerp(MatchCourt.HOOP, 0.18)
	call_deferred("_start_possession", receiving_team, teams[receiving_team].players[0])


func _start_possession(team_id: int, new_ball_owner: MatchPlayer) -> void:
	# Deferred scoring reset waits for the visual basket message, without changing who is human-controlled.
	if reset_cooldown > 0.0:
		await get_tree().create_timer(reset_cooldown).timeout
	possession.team_in_possession = team_id
	possession.set_ball_owner(new_ball_owner)
	ball.hold_by(new_ball_owner)


func _players_for_team(team_id: int) -> Array[MatchPlayer]:
	var result: Array[MatchPlayer] = []
	for player in players:
		if player.team_id == team_id:
			result.append(player)
	return result
