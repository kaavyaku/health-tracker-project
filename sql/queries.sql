-- =====================================
-- 1. APP QUERIES
-- =====================================

-- Recent workouts for one user
SELECT *
FROM workouts
WHERE user_id = 5
ORDER BY workout_date DESC
LIMIT 100;

-- High-intensity recent workouts for one user
SELECT *
FROM workouts
WHERE user_id = 5
  AND intensity = 'high'
ORDER BY workout_date DESC
LIMIT 100;

-- Recent meals for one user
SELECT *
FROM meals
WHERE user_id = 5
ORDER BY meal_date DESC
LIMIT 100;

-- Recent dinners for one user
SELECT *
FROM meals
WHERE user_id = 5
  AND meal_type = 'dinner'
ORDER BY meal_date DESC
LIMIT 50;


-- =====================================
-- 2. EXPLAIN ANALYZE VERSIONS
-- =====================================

EXPLAIN ANALYZE
SELECT *
FROM workouts
WHERE user_id = 5
ORDER BY workout_date DESC
LIMIT 100;

EXPLAIN ANALYZE
SELECT *
FROM workouts
WHERE user_id = 5
  AND intensity = 'high'
ORDER BY workout_date DESC
LIMIT 100;

EXPLAIN ANALYZE
SELECT *
FROM meals
WHERE user_id = 5
ORDER BY meal_date DESC
LIMIT 100;

EXPLAIN ANALYZE
SELECT *
FROM meals
WHERE user_id = 5
  AND meal_type = 'dinner'
ORDER BY meal_date DESC
LIMIT 50;

--- RECOMMENDATION SUPPORTING QUERIES -----

-- user's most common workout categories--

SELECT a.category, COUNT(*) AS category_count
FROM workouts w
JOIN activities a
  ON w.activity_id = a.activity_id
WHERE w.user_id = 5
GROUP BY a.category
ORDER BY category_count DESC
LIMIT 3;

-- recent workout intensity --

SELECT intensity, COUNT(*) AS intensity_count
FROM workouts
WHERE user_id = 5
  AND workout_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY intensity
ORDER BY intensity_count DESC
LIMIT 3;

-- recent nutritional pattern -- 

SELECT meal_type, COUNT(*) AS meal_count
FROM meals
WHERE user_id = 5
  AND meal_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY meal_type
ORDER BY meal_count DESC
LIMIT 3;



---EXPLAIN ANALYZE VERSIONS ---

EXPLAIN ANALYZE
SELECT intensity, COUNT(*) AS intensity_count
FROM workouts
WHERE user_id = 5
  AND workout_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY intensity
ORDER BY intensity_count DESC
LIMIT 3;

EXPLAIN ANALYZE
SELECT a.category, COUNT(*) AS category_count
FROM workouts w
JOIN activities a
  ON w.activity_id = a.activity_id
WHERE w.user_id = 5
GROUP BY a.category
ORDER BY category_count DESC
LIMIT 3;

EXPLAIN ANALYZE
SELECT meal_type, COUNT(*) AS meal_count
FROM meals
WHERE user_id = 5
  AND meal_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY meal_type
ORDER BY meal_count DESC
LIMIT 3;


---- MAKING ACTIVITY INFO MORE READABLE --- 

SELECT w.workout_date, a.activity_name, a.category, w.duration_minutes, w.intensity
FROM workouts w
JOIN activities a
  ON w.activity_id = a.activity_id
WHERE w.user_id = 5
ORDER BY w.workout_date DESC
LIMIT 20;

---- EXPLAIN ANALYZE VERSIONS -------

EXPLAIN ANALYZE
SELECT w.workout_date, a.activity_name, a.category, w.duration_minutes, w.intensity
FROM workouts w
JOIN activities a
  ON w.activity_id = a.activity_id
WHERE w.user_id = 5
ORDER BY w.workout_date DESC
LIMIT 20;

-- =====================================
-- GIN / JSONB QUERIES
-- =====================================

-- Basic GIN query: meals tagged as high protein
SELECT *
FROM meals
WHERE meal_tags @> '{"diet_type": "high_protein"}'
LIMIT 30;

EXPLAIN ANALYZE
SELECT *
FROM meals
WHERE meal_tags @> '{"diet_type": "high_protein"}'
LIMIT 30;

-- Demographic pattern analysis:
-- count high-protein meals across fitness goals
SELECT u.fitness_goal, COUNT(*) AS high_protein_meal_count
FROM meals m
JOIN users u
  ON m.user_id = u.user_id
WHERE m.meal_tags @> '{"diet_type": "high_protein"}'
GROUP BY u.fitness_goal
ORDER BY high_protein_meal_count DESC;

EXPLAIN ANALYZE
SELECT u.fitness_goal, COUNT(*) AS high_protein_meal_count
FROM meals m
JOIN users u
  ON m.user_id = u.user_id
WHERE m.meal_tags @> '{"diet_type": "high_protein"}'
GROUP BY u.fitness_goal
ORDER BY high_protein_meal_count DESC;

-- Demographic pattern analysis:
-- number of distinct users with post-workout meals by experience level
SELECT u.experience_level, COUNT(DISTINCT u.user_id) AS users_with_post_workout_meals
FROM meals m
JOIN users u
  ON m.user_id = u.user_id
WHERE m.meal_tags @> '{"timing": "post_workout"}'
GROUP BY u.experience_level
ORDER BY users_with_post_workout_meals DESC;

EXPLAIN ANALYZE
SELECT u.experience_level, COUNT(DISTINCT u.user_id) AS users_with_post_workout_meals
FROM meals m
JOIN users u
  ON m.user_id = u.user_id
WHERE m.meal_tags @> '{"timing": "post_workout"}'
GROUP BY u.experience_level
ORDER BY users_with_post_workout_meals DESC;

-- Combined JSONB condition with demographic grouping
SELECT u.fitness_goal, COUNT(*) AS meal_prep_high_protein_count
FROM meals m
JOIN users u
  ON m.user_id = u.user_id
WHERE m.meal_tags @> '{"diet_type": "high_protein", "prep": "meal_prep"}'
GROUP BY u.fitness_goal
ORDER BY meal_prep_high_protein_count DESC;

EXPLAIN ANALYZE
SELECT u.fitness_goal, COUNT(*) AS meal_prep_high_protein_count
FROM meals m
JOIN users u
  ON m.user_id = u.user_id
WHERE m.meal_tags @> '{"diet_type": "high_protein", "prep": "meal_prep"}'
GROUP BY u.fitness_goal
ORDER BY meal_prep_high_protein_count DESC;