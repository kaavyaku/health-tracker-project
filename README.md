# Health Tracker App with PostgreSQL 

## Overview
This project is a health and fitness tracking application built on PostgreSQL. It stores user workout and meal data, generates personalized recommendations from past records, and supports broader analytics across groups of users. The main database internals focus is **indexing**, with demonstrations using both **B-tree** and **GIN** indexes.

## Project Goals
This app supports two main goals:

1. **Personalized recommendations**
   - recent workouts and meals are retrieved for a selected user
   - recommendation logic uses recent activity and nutrition patterns

2. **Broader pattern analysis**
   - grouped analytics across demographic-style user attributes such as `fitness_goal` and `experience_level`
   - JSONB-based meal tag analysis using GIN indexes


## Internal Database Focus
The main internal focus area of this project is **indexing in PostgreSQL**.

### Implemented index types
- **B-tree indexes**
  - user/date retrieval
  - filtered workout queries
  - filtered meal queries
  - composite indexes for multi-condition queries

- **GIN index**
  - JSONB containment queries on meal tags using the `@>` operator

### What the project demonstrates
- indexed retrieval vs sequential scan
- overlapping index behavior
- composite B-tree indexes for application queries
- GIN support for JSONB containment queries
- demographic/group analysis over JSONB-tagged data


## Application Features

### User recommendation view
The app allows a user to:
- enter a user ID
- view recent workouts
- view recent meals
- receive a simple rule-based recommendation
- optionally save that recommendation to the database
- option to view index vs no index plan for that query

### Research/admin analytics view
The app also includes an analytics mode that supports grouped pattern tracking queries such as:
- high-protein meal patterns by fitness goal
- distinct users with post-workout meals by experience level
- average workout duration by fitness goal
- option to view index vs no index plan for that query


## Database Schema
Main tables:
- `users`
- `activities`
- `workouts`
- `meals`
- `recommendations`



## How to Run the App
1. Clone the repository or download the project folder
2. Install PostgreSQL and make sure it is running on your computer
3. Create a PostgreSQL database named health_tracker_app
    Example: `createdb -h localhost -p 5432 -U your_username health_tracker_app`
4. Create a .env file. This project uses a .env file to store local PostgreSQL credentials, but it is not included in the GitHub repository because it contains private information. Each user must create their own .env file using .env.example as a template.
5. Install any Python dependencies from requirements.txt. Example: `pip install -r requirements.txt`
6. Run the schema.sql, final_data.sql, and indexes.sql files in the terminal. The sql/final_data.sql file is the dataset for the application, which is a synthetic health dataset. This loads the sample users, workouts, meals, activities, and recommendations into the PostgreSQL database.
    Example: 
    - `psql -h localhost -p 5432 -U your_username -d health_tracker_app -f sql/schema.sql`
    - `psql -h localhost -p 5432 -U your_username -d health_tracker_app -f sql/final_data.sql`
    - `psql -h localhost -p 5432 -U your_username -d health_tracker_app -f sql/indexes.sql`
7. While in the project folder directory, run the app.py file in the command line to start the application
    Example: `python app/app.py`

## Reproduce Results

Running the application with `python app/app.py` reproduces the main application behavior, including viewing recent workouts and meals, generating recommendations, and viewing index versus no-index plans through the menu options.

To reproduce the standalone SQL query and index comparison results used for the report, run:

```bash
psql -h localhost -p 5432 -U your_username -d health_tracker_app -f sql/queries.sql
psql -h localhost -p 5432 -U your_username -d health_tracker_app -f sql/index_comparison_tests.sql
```

## Project Structure
```text
health-tracker-project/
├── .gitignore
├── .env.example
├── README.md
├── run_comparisons.sh
├── requirements.txt
├── app/
│   └── app.py
└── sql/
    ├── schema.sql
    ├── indexes.sql
    ├── seed.sql
    ├── seed_large.sql
    ├── final_data.sql
    ├── queries.sql
    └── index_comparison_tests.sql
```

    