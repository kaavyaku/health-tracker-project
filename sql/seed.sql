INSERT INTO users (name, age, fitness_goal, experience_level)
VALUES
('Alice', 25, 'weight loss', 'beginner'),
('Bob', 31, 'endurance', 'intermediate'),
('Carol', 28, 'muscle gain', 'advanced');

INSERT INTO activities (activity_name, category)
VALUES
('Running', 'cardio'),
('Cycling', 'cardio'),
('Yoga', 'flexibility'),
('Weightlifting', 'strength');

INSERT INTO workouts (user_id, activity_id, workout_date, duration_minutes, calories_burned, avg_heart_rate, intensity, notes)
VALUES
(1, 1, '2026-04-01', 30, 280, 145, 'medium', 'Morning run'),
(1, 3, '2026-04-03', 45, 180, 95, 'low', 'Recovery yoga'),
(2, 2, '2026-04-02', 60, 500, 150, 'high', 'Long bike ride'),
(3, 4, '2026-04-04', 50, 350, 130, 'high', 'Strength session');

INSERT INTO recommendations (user_id, recommended_activity_id, reason)
VALUES
(1, 2, 'Add more cardio variety'),
(2, 1, 'Maintain endurance training'),
(3, 3, 'Add recovery and flexibility work');

INSERT INTO meals (
    user_id,
    meal_date,
    meal_type,
    calories,
    protein_grams,
    carbs_grams,
    fat_grams,
    notes
)
VALUES
(1, '2026-04-01', 'breakfast', 350, 20, 40, 10, 'Greek yogurt with berries and granola'),
(1, '2026-04-01', 'lunch', 600, 35, 55, 18, 'Chicken rice bowl'),
(1, '2026-04-02', 'dinner', 700, 40, 60, 22, 'Salmon with vegetables and quinoa'),
(1, '2026-04-03', 'snack', 220, 12, 25, 8, 'Protein bar'),

(2, '2026-04-01', 'breakfast', 420, 18, 50, 14, 'Oatmeal with banana and peanut butter'),
(2, '2026-04-02', 'lunch', 680, 42, 58, 20, 'Turkey sandwich and fruit'),
(2, '2026-04-03', 'dinner', 750, 45, 70, 24, 'Pasta with chicken'),
(2, '2026-04-04', 'snack', 180, 10, 15, 9, 'Trail mix'),

(3, '2026-04-02', 'breakfast', 390, 22, 35, 16, 'Eggs, toast, and avocado'),
(3, '2026-04-03', 'lunch', 640, 38, 50, 21, 'Tofu stir fry with rice'),
(3, '2026-04-04', 'dinner', 710, 44, 52, 26, 'Steak with sweet potato'),
(3, '2026-04-05', 'snack', 250, 14, 30, 7, 'Smoothie with protein powder');