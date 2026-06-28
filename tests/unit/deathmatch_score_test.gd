extends RefCounted


static func run() -> void:
	_test_accuracy_and_score()


static func _test_accuracy_and_score() -> void:
	var score := DeathmatchScore.new()
	score.record_shot(true)
	score.record_shot(false)
	score.record_kill()
	score.record_death()

	assert(score.kills == 1)
	assert(score.deaths == 1)
	assert(score.shots == 2)
	assert(score.hits == 1)
	assert(score.get_score() == 75)
	assert(score.get_accuracy_percent() == 50.0)
