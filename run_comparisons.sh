#!/bin/bash
echo "Running index comparison tests..."

PSQL_BIN="/Library/PostgreSQL/18/bin/psql"
"$PSQL_BIN" -h localhost -p 5442 -U kaavyakumar -d health_tracker_app -f sql/index_comparison_tests.sql