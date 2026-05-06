INSERT INTO users (name, age, fitness_goal, experience_level)
SELECT
    'User_' || gs,
    18 + (gs % 43),
    (ARRAY['weight loss', 'muscle gain', 'endurance', 'general fitness'])[1 + (gs % 4)],
    (ARRAY['beginner', 'intermediate', 'advanced'])[1 + (gs % 3)]
FROM generate_series(1, 30) AS gs;

INSERT INTO activities (activity_name, category)
VALUES
('Running', 'cardio'),
('Cycling', 'cardio'),
('Swimming', 'cardio'),
('Walking', 'cardio'),
('Weightlifting', 'strength'),
('Bodyweight Training', 'strength'),
('Yoga', 'flexibility'),
('Pilates', 'flexibility'),
('HIIT', 'cardio'),
('Rowing', 'cardio');

INSERT INTO workouts (
    user_id,
    activity_id,
    workout_date,
    duration_minutes,
    calories_burned,
    avg_heart_rate,
    intensity,
    notes
)
SELECT
    1 + floor(random() * 30)::int AS user_id,
    1 + floor(random() * 10)::int AS activity_id,
    DATE '2025-01-01' + floor(random() * 365)::int AS workout_date,
    20 + floor(random() * 71)::int AS duration_minutes,
    150 + floor(random() * 551)::int AS calories_burned,
    85 + floor(random() * 91)::int AS avg_heart_rate,
    (ARRAY['low', 'medium', 'high'])[1 + floor(random() * 3)::int] AS intensity,
    (ARRAY[
        'Morning session',
        'Evening workout',
        'Recovery training',
        'Strength focus',
        'Cardio session',
        'Weekend workout'
    ])[1 + floor(random() * 6)::int] AS notes
FROM generate_series(1, 3000);

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
SELECT
    1 + floor(random() * 30)::int AS user_id,
    DATE '2025-01-01' + floor(random() * 365)::int AS meal_date,
    (ARRAY['breakfast', 'lunch', 'dinner', 'snack'])[1 + floor(random() * 4)::int] AS meal_type,
    200 + floor(random() * 801)::int AS calories,
    5 + floor(random() * 56)::int AS protein_grams,
    10 + floor(random() * 91)::int AS carbs_grams,
    5 + floor(random() * 41)::int AS fat_grams,
    (ARRAY[
        'High protein meal',
        'Post workout meal',
        'Balanced meal',
        'Quick snack',
        'Meal prep lunch',
        'Recovery dinner'
    ])[1 + floor(random() * 6)::int] AS notes
FROM generate_series(1, 3000);

INSERT INTO recommendations (
    user_id,
    recommended_activity_id,
    reason
)
SELECT
    1 + floor(random() * 30)::int AS user_id,
    1 + floor(random() * 10)::int AS recommended_activity_id,
    (ARRAY[
        'Increase cardio consistency',
        'Add more recovery sessions',
        'Improve strength balance',
        'Support endurance goals',
        'Increase flexibility training'
    ])[1 + floor(random() * 5)::int] AS reason
FROM generate_series(1, 100);