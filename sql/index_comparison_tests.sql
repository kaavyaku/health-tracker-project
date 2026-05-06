\pset pager off

-- =====================================
-- INDEX COMPARISON TESTS
-- =====================================

-- NOTE:
-- This demo version runs the two most representative comparison tests:
-- 1) a composite B-tree index comparison for filtered workout retrieval
-- 2) a GIN index comparison for JSONB demographic pattern analysis
--
-- Additional comparison tests are included in commented form below
-- and can be re-enabled if needed.


-- -------------------------------------
-- 1. Compare recent workouts query
-- -------------------------------------

--\echo '=== TEST 1: WITH WORKOUT INDEXES ==='
--EXPLAIN ANALYZE
--SELECT *
--FROM workouts
--WHERE user_id = 5
--ORDER BY workout_date DESC;

--\echo '=== TEST 1: DROPPING SUPPORTING WORKOUT INDEXES ==='
--DROP INDEX IF EXISTS idx_workouts_user_date;
--DROP INDEX IF EXISTS idx_workouts_user_intensity_date;

--\echo '=== TEST 1: WITHOUT SUPPORTING WORKOUT INDEXES ==='
--EXPLAIN ANALYZE
--SELECT *
--FROM workouts
--WHERE user_id = 5
--ORDER BY workout_date DESC;

--\echo '=== TEST 1: RECREATING WORKOUT INDEXES ==='
--CREATE INDEX idx_workouts_user_date
--ON workouts(user_id, workout_date DESC);

--CREATE INDEX idx_workouts_user_intensity_date
--ON workouts(user_id, intensity, workout_date DESC);



-- -------------------------------------
-- 2. Compare filtered workouts query
-- Query: WHERE user_id = 5 AND intensity = 'high' ORDER BY workout_date DESC
-- Drop both workout indexes again so PostgreSQL cannot still use one of them
-- -------------------------------------

\echo '=== B-TREE INDEX TEST: WITH FILTERED WORKOUT INDEXES ==='
EXPLAIN ANALYZE
SELECT *
FROM workouts
WHERE user_id = 5
  AND intensity = 'high'
ORDER BY workout_date DESC;

\echo '=== B-TREE INDEX TEST: DROPPING ALL SUPPORTING WORKOUT INDEXES ==='
DROP INDEX IF EXISTS idx_workouts_user_date;
DROP INDEX IF EXISTS idx_workouts_user_intensity_date;
DROP INDEX IF EXISTS idx_workouts_intensity;

\echo '=== B-TREE INDEX TEST: WITHOUT SUPPORTING WORKOUT INDEXES ==='
EXPLAIN ANALYZE
SELECT *
FROM workouts
WHERE user_id = 5
  AND intensity = 'high'
ORDER BY workout_date DESC;

\echo '=== B-TREE INDEX TEST: RECREATING WORKOUT INDEXES ==='
CREATE INDEX idx_workouts_user_date
ON workouts(user_id, workout_date DESC);

CREATE INDEX idx_workouts_intensity
ON workouts(intensity);

CREATE INDEX idx_workouts_user_intensity_date
ON workouts(user_id, intensity, workout_date DESC);



-- -------------------------------------
-- 3. Compare filtered meals query
-- -------------------------------------

--\echo '=== TEST 3: WITH MEAL INDEXES ==='
--EXPLAIN ANALYZE
--SELECT *
--FROM meals
--WHERE user_id = 5
--  AND meal_type = 'dinner'
--ORDER BY meal_date DESC;

--\echo '=== TEST 3: DROPPING ALL SUPPORTING MEAL INDEXES ==='
--DROP INDEX IF EXISTS idx_meals_user_mealtype_date;
--DROP INDEX IF EXISTS idx_meals_user_date;
--DROP INDEX IF EXISTS idx_meals_meal_type;

--\echo '=== TEST 3: WITHOUT SUPPORTING MEAL INDEXES ==='
--EXPLAIN ANALYZE
--SELECT *
--FROM meals
--WHERE user_id = 5
--  AND meal_type = 'dinner'
--ORDER BY meal_date DESC;

--\echo '=== TEST 3: RECREATING MEAL INDEXES ==='
--CREATE INDEX idx_meals_user_mealtype_date
--ON meals(user_id, meal_type, meal_date DESC);

--CREATE INDEX idx_meals_user_date
--ON meals(user_id, meal_date DESC);

--CREATE INDEX idx_meals_meal_type
--ON meals(meal_type);


---- test 4: using GIN indexing this time to compare meal tags ------

--\echo '=== GIN INDEX TEST: WITH DIET INDEX ==='
--EXPLAIN ANALYZE
--SELECT *
--FROM meals
--WHERE meal_tags @> '{"diet_type": "high_protein"}';

--\echo '=== GIN INDEX TEST: DROPPING INDEX ==='
--DROP INDEX IF EXISTS idx_meals_tags_gin;

--\echo '=== GIN INDEX TEST: WITHOUT INDEX ==='
--EXPLAIN ANALYZE
--SELECT *
--FROM meals
--WHERE meal_tags @> '{"diet_type": "high_protein"}';

--\echo '=== GIN INDEX TEST: RECREATING INDEX ==='
--CREATE INDEX idx_meals_tags_gin
--ON meals
--USING GIN(meal_tags);



--- test 5: showing how demographic test changes once the GIN index is dropped -- 


\echo '=== GIN INDEX TEST: WITH INDEX (DEMOGRAPHIC QUERY) ==='
EXPLAIN ANALYZE
SELECT u.fitness_goal, COUNT(*) AS high_protein_meal_count
FROM meals m
JOIN users u
  ON m.user_id = u.user_id
WHERE m.meal_tags @> '{"diet_type": "high_protein", "prep": "meal_prep"}'
GROUP BY u.fitness_goal
ORDER BY high_protein_meal_count DESC;

\echo '=== GIN INDEX TEST: DROPPING INDEX ==='
DROP INDEX IF EXISTS idx_meals_tags_gin;

\echo '=== GIN INDEX TEST: WITHOUT INDEX (DEMOGRAPHIC QUERY) ==='
EXPLAIN ANALYZE
SELECT u.fitness_goal, COUNT(*) AS high_protein_meal_count
FROM meals m
JOIN users u
  ON m.user_id = u.user_id
WHERE m.meal_tags @> '{"diet_type": "high_protein", "prep": "meal_prep"}'
GROUP BY u.fitness_goal
ORDER BY high_protein_meal_count DESC;

\echo '=== GIN INDEX TEST: RECREATING INDEX ==='
CREATE INDEX idx_meals_tags_gin
ON meals
USING GIN(meal_tags);
