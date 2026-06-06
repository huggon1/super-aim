class_name ScoreTracker
extends RefCounted

const DEFAULT_SCORE_PER_HIT := 100

var hits := 0
var shots := 0
var score_per_hit := DEFAULT_SCORE_PER_HIT


func reset() -> void:
	hits = 0
	shots = 0


func record_shot(was_hit: bool) -> void:
	shots += 1
	if was_hit:
		hits += 1


func get_accuracy() -> float:
	if shots == 0:
		return 0.0
	return float(hits) / float(shots)


func get_accuracy_percent() -> float:
	return get_accuracy() * 100.0


func get_score() -> int:
	return hits * score_per_hit


func get_results(duration_seconds: float) -> Dictionary:
	return {
		"duration_seconds": duration_seconds,
		"hits": hits,
		"shots": shots,
		"accuracy_percent": get_accuracy_percent(),
		"score": get_score(),
	}
