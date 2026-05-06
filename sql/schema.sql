CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    age INT,
    fitness_goal TEXT NOT NULL,
    experience_level TEXT NOT NULL
);

CREATE TABLE activities (
    activity_id SERIAL PRIMARY KEY,
    activity_name TEXT NOT NULL,
    category TEXT NOT NULL
);

CREATE TABLE workouts (
    workout_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    activity_id INT NOT NULL,
    workout_date DATE NOT NULL,
    duration_minutes INT NOT NULL,
    calories_burned INT,
    avg_heart_rate INT,
    intensity TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_workouts_user
        FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_workouts_activity
        FOREIGN KEY (activity_id) REFERENCES activities(activity_id)
);

CREATE TABLE recommendations (
    recommendation_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    recommended_activity_id INT NOT NULL,
    reason TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_recommendations_user
        FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_recommendations_activity
        FOREIGN KEY (recommended_activity_id) REFERENCES activities(activity_id)
);

CREATE TABLE meals (
    meal_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    meal_date DATE NOT NULL,
    meal_type TEXT NOT NULL,
    calories INT,
    protein_grams INT,
    carbs_grams INT,
    fat_grams INT,
    notes TEXT,
    meal_tags JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_meals_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
);