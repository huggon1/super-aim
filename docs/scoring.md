# Scoring

V1 scoring is intentionally simple:

- Every shot increments `shots`.
- Every hit increments `hits`.
- Accuracy is `hits / shots * 100`.
- Zero shots reports 0% accuracy.
- Score is `hits * 100`.

Keep scoring logic in `ScoreTracker` so future formulas can be tested without loading a scene.
