#!/bin/bash

# FitLog test runner script.
# Runs both python unit tests (sports_tracker_extractor) and flutter unit/widget tests (fitlog_app).

# Color Codes
GREEN='\e[1;32m'
RED='\e[1;31m'
YELLOW='\e[1;33m'
NC='\e[0m' # No Color

EXIT_CODE=0

echo "========================================"
echo "      Running FitLog Project Tests     "
echo "========================================"
echo ""

# 1. Run Python tests (sports_tracker_extractor)
echo ">>> [1/2] Running Sports Tracker Extractor Python Tests..."
if [ -d "sports_tracker_extractor" ]; then
    cd sports_tracker_extractor
    if [ -f "venv/bin/python" ]; then
        ./venv/bin/python -m unittest discover -s tests
        PYTHON_STATUS=$?
    else
        echo -e "${YELLOW}Warning: Python virtual environment (venv) not found. Trying system python3...${NC}"
        python3 -m unittest discover -s tests
        PYTHON_STATUS=$?
    fi
    cd ..
    if [ $PYTHON_STATUS -ne 0 ]; then
        echo -e "${RED}Python tests failed!${NC}"
        EXIT_CODE=1
    else
        echo -e "${GREEN}Python tests passed!${NC}"
    fi
else
    echo -e "${RED}Error: sports_tracker_extractor directory not found!${NC}"
    EXIT_CODE=1
fi

echo ""
echo "----------------------------------------"
echo ""

# 2. Run Flutter tests (fitlog_app)
echo ">>> [2/2] Running FitLog App Flutter Tests..."
if [ -d "fitlog_app" ]; then
    cd fitlog_app
    flutter test
    FLUTTER_STATUS=$?
    cd ..
    if [ $FLUTTER_STATUS -ne 0 ]; then
        echo -e "${RED}Flutter tests failed!${NC}"
        EXIT_CODE=1
    else
        echo -e "${GREEN}Flutter tests passed!${NC}"
    fi
else
    echo -e "${RED}Error: fitlog_app directory not found!${NC}"
    EXIT_CODE=1
fi

echo ""
echo "========================================"
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}All tests passed successfully!${NC}"
else
    echo -e "${RED}Some tests failed. Please check the logs above.${NC}"
fi
echo "========================================"

exit $EXIT_CODE
