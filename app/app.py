import os
from typing import Optional, Tuple

import psycopg2
from psycopg2.extensions import connection as PGConnection
from dotenv import load_dotenv


load_dotenv()

RECENT_WORKOUTS_QUERY = """
SELECT w.workout_date,
       a.activity_name,
       a.category,
       w.duration_minutes,
       w.calories_burned,
       w.avg_heart_rate,
       w.intensity,
       w.notes
FROM workouts w
JOIN activities a
  ON w.activity_id = a.activity_id
WHERE w.user_id = %s
ORDER BY w.workout_date DESC
LIMIT %s;
"""

RECENT_MEALS_QUERY = """
SELECT meal_date,
       meal_type,
       calories,
       protein_grams,
       carbs_grams,
       fat_grams,
       notes,
       meal_tags
FROM meals
WHERE user_id = %s
ORDER BY meal_date DESC
LIMIT %s;
"""

TOP_WORKOUT_CATEGORY_QUERY = """
SELECT a.category, COUNT(*) AS category_count
FROM workouts w
JOIN activities a
  ON w.activity_id = a.activity_id
WHERE w.user_id = %s
  AND w.workout_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY a.category
ORDER BY category_count DESC
LIMIT 1;
"""

TOP_RECENT_INTENSITY_QUERY = """
SELECT intensity, COUNT(*) AS intensity_count
FROM workouts
WHERE user_id = %s
  AND workout_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY intensity
ORDER BY intensity_count DESC
LIMIT 1;
"""

TOP_RECENT_MEAL_TYPE_QUERY = """
SELECT meal_type, COUNT(*) AS meal_count
FROM meals
WHERE user_id = %s
  AND meal_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY meal_type
ORDER BY meal_count DESC
LIMIT 1;
"""

ADMIN_HIGH_PROTEIN_BY_GOAL_QUERY = """
SELECT u.fitness_goal, COUNT(*) AS high_protein_meal_count
FROM meals m
JOIN users u
  ON m.user_id = u.user_id
WHERE m.meal_tags @> '{"diet_type": "high_protein", "prep": "meal_prep"}'
GROUP BY u.fitness_goal
ORDER BY high_protein_meal_count DESC;
"""

ADMIN_POST_WORKOUT_BY_EXPERIENCE_QUERY = """
SELECT u.experience_level, COUNT(DISTINCT u.user_id) AS users_with_post_workout_meals
FROM meals m
JOIN users u
  ON m.user_id = u.user_id
WHERE m.meal_tags @> '{"timing": "post_workout"}'
GROUP BY u.experience_level
ORDER BY users_with_post_workout_meals DESC;
"""

ADMIN_AVG_WORKOUT_DURATION_BY_GOAL_QUERY = """
SELECT u.fitness_goal, AVG(w.duration_minutes) AS avg_duration
FROM users u
JOIN workouts w
    ON u.user_id = w.user_id
WHERE w.workout_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY u.fitness_goal
ORDER BY avg_duration DESC;
"""

def get_connection() -> PGConnection:
    """Create and return a PostgreSQL connection from environment variables."""
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
    )

def explain_query(conn: PGConnection, query: str, params=None, force_seq: bool = False):
    """
    Return EXPLAIN ANALYZE output as a list of lines.
    If force_seq=True, temporarily disable index-based plans.
    """
    params = params or ()

    with conn.cursor() as cur:
        if force_seq:
            cur.execute("BEGIN;")
            cur.execute("SET LOCAL enable_indexscan = off;")
            cur.execute("SET LOCAL enable_indexonlyscan = off;")
            cur.execute("SET LOCAL enable_bitmapscan = off;")
            cur.execute("EXPLAIN (ANALYZE, BUFFERS) " + query, params)
            rows = cur.fetchall()
            cur.execute("ROLLBACK;")
        else:
            cur.execute("EXPLAIN (ANALYZE, BUFFERS) " + query, params)
            rows = cur.fetchall()

    return [row[0] for row in rows]


def print_plan_comparison(conn: PGConnection, title: str, query: str, params=None) -> None:
    print("\n" + "=" * 70)
    print(f"QUERY PLAN COMPARISON: {title}")
    print("=" * 70)

    print("\n--- WITH INDEXES PLAN ---")
    indexed_plan = explain_query(conn, query, params=params, force_seq=False)
    for line in indexed_plan:
        print(line)

    print("\n--- NO INDEX SEQUENTIAL SCAN PLAN ---")
    non_index_plan = explain_query(conn, query, params=params, force_seq=True)
    for line in non_index_plan:
        print(line)


def prompt_for_plan_comparison(conn: PGConnection, title: str, query: str, params=None) -> None:
    choice = input("\nShow indexed vs non-index query plan comparison? (y/n): ").strip().lower()
    if choice == "y":
        print_plan_comparison(conn, title, query, params=params)


def get_recent_workouts(conn: PGConnection, user_id: int, limit: int = 5):
    with conn.cursor() as cur:
        cur.execute(RECENT_WORKOUTS_QUERY, (user_id, limit))
        return cur.fetchall()


def get_recent_meals(conn: PGConnection, user_id: int, limit: int = 5):
    with conn.cursor() as cur:
        cur.execute(RECENT_MEALS_QUERY, (user_id, limit))
        return cur.fetchall()


def get_top_workout_category(conn: PGConnection, user_id: int) -> Optional[Tuple[str, int]]:
    with conn.cursor() as cur:
        cur.execute(TOP_WORKOUT_CATEGORY_QUERY, (user_id,))
        return cur.fetchone()


def get_top_recent_intensity(conn: PGConnection, user_id: int) -> Optional[Tuple[str, int]]:
    with conn.cursor() as cur:
        cur.execute(TOP_RECENT_INTENSITY_QUERY, (user_id,))
        return cur.fetchone()


def get_top_recent_meal_type(conn: PGConnection, user_id: int) -> Optional[Tuple[str, int]]:
    with conn.cursor() as cur:
        cur.execute(TOP_RECENT_MEAL_TYPE_QUERY, (user_id,))
        return cur.fetchone()


def get_high_protein_meals_by_goal(conn: PGConnection):
    with conn.cursor() as cur:
        cur.execute(ADMIN_HIGH_PROTEIN_BY_GOAL_QUERY)
        return cur.fetchall()


def get_post_workout_meals_by_experience(conn: PGConnection):
    with conn.cursor() as cur:
        cur.execute(ADMIN_POST_WORKOUT_BY_EXPERIENCE_QUERY)
        return cur.fetchall()


def get_avg_workout_duration_by_goal(conn: PGConnection):
    with conn.cursor() as cur:
        cur.execute(ADMIN_AVG_WORKOUT_DURATION_BY_GOAL_QUERY)
        return cur.fetchall()
    
def get_top_diet_type(conn: PGConnection, user_id: int) -> Optional[Tuple[str, int]]:
    query = """
    SELECT meal_tags->>'diet_type' AS diet_type, COUNT(*) AS meal_count
    FROM meals
    WHERE user_id = %s
      AND meal_date >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY meal_tags->>'diet_type'
    ORDER BY meal_count DESC
    LIMIT 1;
    """
    with conn.cursor() as cur:
        cur.execute(query, (user_id,))
        return cur.fetchone()


def generate_workout_recommendation(conn: PGConnection, user_id: int) -> Tuple[str, str]:
    top_category = get_top_workout_category(conn, user_id)
    top_intensity = get_top_recent_intensity(conn, user_id)

    if top_intensity and top_intensity[0] == "high":
        return (
            "Yoga",
            "Recent workouts are mostly high intensity, so a recovery-focused activity is recommended."
        )

    if top_category and top_category[0] == "cardio":
        return (
            "Weightlifting",
            "Recent workouts are mostly cardio, so a strength-focused activity is recommended for balance."
        )

    if top_category and top_category[0] == "flexibility":
        return (
            "Running",
            "Recent workouts are mostly flexibility-based, so adding more cardio is recommended for balance."
        )

    if top_category and top_category[0] == "strength":
        return (
            "Walking",
            "Recent workouts are mostly strength-focused, so a lighter cardio activity is recommended for balance."
        )

    return (
        "Walking",
        "A general low-impact activity is recommended to maintain consistency."
    )


def generate_meal_recommendation(conn: PGConnection, user_id: int) -> Tuple[str, str]:
    top_meal_type = get_top_recent_meal_type(conn, user_id)
    top_diet_type = get_top_diet_type(conn, user_id)

    if top_meal_type and top_meal_type[0] == "snack":
        return (
            "Meal Planning",
            "Recent meals are snack-heavy, so more balanced meals are recommended."
        )

    if top_diet_type and top_diet_type[0] == "high_protein":
        return (
            "Weightlifting",
            "Recent meals are mostly high protein, which pairs well with strength-focused training."
        )

    if top_diet_type and top_diet_type[0] == "low_carb":
        return (
            "Walking",
            "Recent meals are mostly low carb, so a lower-impact consistency-focused activity is recommended."
        )

    return (
        "Walking",
        "A general low-impact activity is recommended to maintain healthy consistency."
    )


def save_recommendation(conn: PGConnection, user_id: int, activity_name: str, reason: str) -> None:
    """
    Save the recommendation into the recommendations table if the activity exists.
    """
    lookup_query = """
    SELECT activity_id
    FROM activities
    WHERE activity_name = %s
    LIMIT 1;
    """

    insert_query = """
    INSERT INTO recommendations (user_id, recommended_activity_id, reason)
    VALUES (%s, %s, %s);
    """

    with conn.cursor() as cur:
        cur.execute(lookup_query, (activity_name,))
        row = cur.fetchone()

        if row is None:
            print(f"Could not save recommendation: activity '{activity_name}' was not found in activities.")
            return

        recommended_activity_id = row[0]
        cur.execute(insert_query, (user_id, recommended_activity_id, reason))
        conn.commit()


def print_recent_workouts(conn: PGConnection, user_id: int) -> None:
    workouts = get_recent_workouts(conn, user_id)

    print("\nRecent workouts:")
    if not workouts:
        print("No workouts found.")
        return

    for row in workouts:
        workout_date, activity_name, category, duration, calories, heart_rate, intensity, notes = row
        print(
            f"- {workout_date} | {activity_name} ({category}) | "
            f"{duration} min | intensity={intensity} | calories={calories} | "
            f"heart_rate={heart_rate} | notes={notes}"
        )


def print_recent_meals(conn: PGConnection, user_id: int) -> None:
    meals = get_recent_meals(conn, user_id)

    print("\nRecent meals:")
    if not meals:
        print("No meals found.")
        return

    for row in meals:
        meal_date, meal_type, calories, protein, carbs, fat, notes, meal_tags = row
        print(
            f"- {meal_date} | {meal_type} | calories={calories} | "
            f"protein={protein}g | carbs={carbs}g | fat={fat}g | "
            f"notes={notes} | tags={meal_tags}"
        )

def print_admin_analytics(conn: PGConnection) -> None:
    while True:
        print("\n==============================")
        print("Research/Admin Analytics")
        print("1. High-protein meals by fitness goal")
        print("2. Distinct users with post-workout meals by experience level")
        print("3. Average recent workout duration by fitness goal")
        print("4. Back to main menu")
        print("==============================")

        choice = input("Choose an analytics option: ").strip()

        if choice == "1":
            results = get_high_protein_meals_by_goal(conn)
            print("\nHigh-protein meals by fitness goal:")
            for goal, count in results:
                print(f"- {goal}: {count}")

            prompt_for_plan_comparison(
                conn,
                "High-protein meals by fitness goal",
                ADMIN_HIGH_PROTEIN_BY_GOAL_QUERY
            )

        elif choice == "2":
            results = get_post_workout_meals_by_experience(conn)
            print("\nDistinct users with at least one post-workout meal, by experience level:")
            for level, count in results:
                print(f"- {level}: {count}")

            prompt_for_plan_comparison(
                conn,
                "Distinct users with post-workout meals by experience level",
                ADMIN_POST_WORKOUT_BY_EXPERIENCE_QUERY
            )

        elif choice == "3":
            results = get_avg_workout_duration_by_goal(conn)
            print("\nAverage recent workout duration by fitness goal:")
            for goal, avg_duration in results:
                print(f"- {goal}: {avg_duration:.2f} minutes")

            prompt_for_plan_comparison(
                conn,
                "Average recent workout duration by fitness goal",
                ADMIN_AVG_WORKOUT_DURATION_BY_GOAL_QUERY
            )

        elif choice == "4":
            print("Returning to main menu.")
            break

        else:
            print("Invalid analytics option.")

        input("\nPress Enter to continue...")

def run_user_mode(conn: PGConnection) -> None:
    raw_user_id = input("Enter user ID: ").strip()
    if not raw_user_id.isdigit():
        print("User ID must be a number.")
        return

    user_id = int(raw_user_id)

    print("\n==============================")
    print("User Recommendation View")
    print("1. Show recent workouts")
    print("2. Show recent meals")
    print("3. Back to main menu")
    print("==============================")

    choice = input("Choose an option: ").strip()

    if choice == "3":
        print("Returning to main menu.")
        return

    if choice == "1":
        print_recent_workouts(conn, user_id)

        activity_name, reason = generate_workout_recommendation(conn, user_id)
        print("\nRecommendation:")
        print(f"Recommended activity: {activity_name}")
        print(f"Reason: {reason}")

        save_choice = input("\nSave this recommendation to the database? (y/n): ").strip().lower()
        if save_choice == "y":
            save_recommendation(conn, user_id, activity_name, reason)
            print("Recommendation saved.")
        else:
            print("Recommendation not saved.")

        prompt_for_plan_comparison(
            conn,
            "Recent workouts for user",
            """
            SELECT w.workout_date,
                   a.activity_name,
                   a.category,
                   w.duration_minutes,
                   w.calories_burned,
                   w.avg_heart_rate,
                   w.intensity,
                   w.notes
            FROM workouts w
            JOIN activities a
              ON w.activity_id = a.activity_id
            WHERE w.user_id = %s
            ORDER BY w.workout_date DESC
            LIMIT %s;
            """,
            (user_id, 5)
        )

        input("\nPress Enter to return to the main menu...")
        return

    elif choice == "2":
        print_recent_meals(conn, user_id)

        activity_name, reason = generate_meal_recommendation(conn, user_id)
        print("\nRecommendation:")
        print(f"Recommended activity: {activity_name}")
        print(f"Reason: {reason}")

        save_choice = input("\nSave this recommendation to the database? (y/n): ").strip().lower()
        if save_choice == "y":
            save_recommendation(conn, user_id, activity_name, reason)
            print("Recommendation saved.")
        else:
            print("Recommendation not saved.")

        prompt_for_plan_comparison(
            conn,
            "Recent meals for user",
            """
            SELECT meal_date,
                   meal_type,
                   calories,
                   protein_grams,
                   carbs_grams,
                   fat_grams,
                   notes,
                   meal_tags
            FROM meals
            WHERE user_id = %s
            ORDER BY meal_date DESC
            LIMIT %s;
            """,
            (user_id, 5)
        )

        input("\nPress Enter to return to the main menu...")
        return

    else:
        print("Invalid option.")
        return


def main() -> None:
    try:
        conn = get_connection()
    except Exception as exc:
        print("Failed to connect to PostgreSQL.")
        print(f"Error: {exc}")
        return

    try:
        while True:
            print("\n==============================")
            print("Health Tracker App")
            print("1. User recommendation view")
            print("2. Research/admin analytics view")
            print("3. Exit")
            print("==============================")

            mode = input("Enter choice: ").strip()

            if mode == "1":
                run_user_mode(conn)
            elif mode == "2":
                print_admin_analytics(conn)
            elif mode == "3":
                print("Exiting app.")
                break
            else:
                print("Invalid mode selected.")

    finally:
        conn.close()


if __name__ == "__main__":
    main()
