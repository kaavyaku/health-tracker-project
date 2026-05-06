CREATE INDEX idx_workouts_user_date
ON workouts(user_id, workout_date DESC);

CREATE INDEX idx_workouts_activity
ON workouts(activity_id);

CREATE INDEX idx_workouts_intensity
ON workouts(intensity);

CREATE INDEX idx_workouts_user_intensity_date
ON workouts(user_id, intensity, workout_date DESC);

CREATE INDEX idx_meals_user_date
ON meals(user_id, meal_date DESC);

CREATE INDEX idx_meals_meal_type
ON meals(meal_type);

CREATE INDEX idx_meals_user_mealtype_date
ON meals(user_id, meal_type, meal_date DESC);

CREATE INDEX idx_meals_tags_gin
ON meals
USING GIN(meal_tags);

CREATE INDEX idx_workouts_date_user
ON workouts(workout_date, user_id);