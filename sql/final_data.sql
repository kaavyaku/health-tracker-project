

TRUNCATE TABLE recommendations, meals, workouts, activities, users RESTART IDENTITY CASCADE;

SELECT setseed(0.42);

-- creating 50 synthetic users, generating varied ages that are in between 18 and 60,
    -- since they are most likely to use a health tracking application

INSERT INTO users (name, age, fitness_goal, experience_level)
SELECT
    'User_' || gs,
    18 + ((gs * 3) % 43),
    (ARRAY['weight loss', 'muscle gain', 'endurance', 'general fitness'])[1 + ((gs - 1) % 4)],
    (ARRAY['beginner', 'intermediate', 'advanced'])[1 + ((gs - 1) % 3)]
FROM generate_series(1, 50) AS gs;

-- generating activity types 

INSERT INTO activities (activity_name, category)
VALUES
('Running', 'cardio'),
('Cycling', 'cardio'),
('Swimming', 'cardio'),
('Walking', 'cardio'),
('Rowing', 'cardio'),
('HIIT', 'cardio'),
('Weightlifting', 'strength'),
('Bodyweight Training', 'strength'),
('Resistance Bands', 'strength'),
('Yoga', 'flexibility'),
('Pilates', 'flexibility'),
('Stretching', 'flexibility');

-- -------------------------------------
-- 3. WORKOUTS (15,000)
-- Dates are recent enough for CURRENT_DATE - INTERVAL '30 days' queries
-- -------------------------------------
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
    1 + floor(random() * 50)::int AS user_id,
    1 + floor(random() * 12)::int AS activity_id,
    CURRENT_DATE - floor(random() * 180)::int AS workout_date,
    20 + floor(random() * 71)::int AS duration_minutes,
    180 + floor(random() * 620)::int AS calories_burned,
    85 + floor(random() * 95)::int AS avg_heart_rate,
    (ARRAY['low', 'medium', 'high'])[1 + floor(random() * 3)::int] AS intensity,
    (ARRAY[
        'Morning session',
        'Evening workout',
        'Recovery day',
        'Cardio focus',
        'Strength focus',
        'Weekend session'
    ])[1 + floor(random() * 6)::int] AS notes
FROM generate_series(1, 15000);

-- -------------------------------------
-- 4. MEALS (15,000)
-- Also recent enough for recent-pattern queries
-- -------------------------------------
INSERT INTO meals (
    user_id,
    meal_date,
    meal_type,
    calories,
    protein_grams,
    carbs_grams,
    fat_grams,
    notes,
    meal_tags
)
SELECT
    1 + floor(random() * 50)::int AS user_id,
    CURRENT_DATE - floor(random() * 180)::int AS meal_date,
    (ARRAY['breakfast', 'lunch', 'dinner', 'snack'])[1 + floor(random() * 4)::int] AS meal_type,
    220 + floor(random() * 780)::int AS calories,
    8 + floor(random() * 55)::int AS protein_grams,
    15 + floor(random() * 95)::int AS carbs_grams,
    5 + floor(random() * 40)::int AS fat_grams,
    (ARRAY[
        'Balanced meal',
        'High protein meal',
        'Post workout meal',
        'Meal prep lunch',
        'Quick snack',
        'Recovery dinner'
    ])[1 + floor(random() * 6)::int] AS notes,
    jsonb_build_object(
        'diet_type',
        (ARRAY['high_protein', 'balanced', 'low_carb', 'vegetarian'])[1 + floor(random() * 4)::int],
        'timing',
        (ARRAY['pre_workout', 'post_workout', 'breakfast', 'dinner'])[1 + floor(random() * 4)::int],
        'prep',
        (ARRAY['home_cooked', 'meal_prep', 'takeout'])[1 + floor(random() * 3)::int]
    ) AS meal_tags
FROM generate_series(1, 15000);
-- -------------------------------------
-- 5. RECOMMENDATIONS (200)
-- -------------------------------------
INSERT INTO recommendations (
    user_id,
    recommended_activity_id,
    reason
)
SELECT
    1 + ((gs - 1) % 50) AS user_id,
    1 + ((gs * 5) % 12) AS recommended_activity_id,
    (ARRAY[
        'Increase cardio consistency',
        'Add more recovery sessions',
        'Improve strength balance',
        'Support endurance goals',
        'Increase flexibility training'
    ])[1 + ((gs * 2) % 5)] AS reason
FROM generate_series(1, 200) AS gs;