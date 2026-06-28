class_name DeathmatchScore
extends RefCounted

var kills := 0
var deaths := 0
var shots := 0
var hits := 0


func record_shot(was_hit: bool) -> void:
	shots += 1
	if was_hit:
		hits += 1


func record_kill() -> void:
	kills += 1


func record_death() -> void:
	deaths += 1


func get_score() -> int:
	return kills * 100 - deaths * 25


func get_accuracy_percent() -> float:
	if shots == 0:
		return 0.0
	return float(hits) / float(shots) * 100.0


func get_results(duration_seconds: float) -> Dictionary:
	return {
		"score": get_score(),
		"hits": hits,
		"shots": shots,
		"accuracy_percent": get_accuracy_percent(),
		"kills": kills,
		"deaths": deaths,
		"duration_seconds": duration_seconds,
	}
