#!/bin/bash
# add-paper.sh - Interactive script to add a new paper to the website
# Usage: ./add-paper.sh
# After running, drop the PDF into the papers/ folder

set -e

DATA_FILE="data/papers.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_PATH="$SCRIPT_DIR/$DATA_FILE"

if [ ! -f "$DATA_PATH" ]; then
  echo "Error: $DATA_PATH not found. Run this script from the Website directory."
  exit 1
fi

echo "=== Add a New Paper ==="
echo ""

read -p "Title? > " TITLE
read -p "Venue (journal or volume name)? > " VENUE
read -p "Venue details (e.g., 'vol. 5, 2024, pp. 1-30' or 'edited by X, OUP, 2024')? > " VENUE_DETAIL
read -p "Year (or 'forthcoming')? > " YEAR
read -p "Sort year (numeric, for ordering - use expected year if forthcoming)? > " SORT_YEAR
read -p "Type (article/chapter/reference)? > " TYPE

echo ""
echo "Is this a selected/highlighted work? (y/n)"
read -p "> " SELECTED_YN
SELECTED=false
if [ "$SELECTED_YN" = "y" ] || [ "$SELECTED_YN" = "Y" ]; then
  SELECTED=true
fi

read -p "PDF filename (just the filename, e.g., 'My_Paper.pdf' - must be in papers/ folder)? > " PDF_FILENAME

echo ""
echo "Paste the abstract (press Enter twice when done):"
ABSTRACT=""
while IFS= read -r line; do
  [ -z "$line" ] && break
  if [ -n "$ABSTRACT" ]; then
    ABSTRACT="$ABSTRACT $line"
  else
    ABSTRACT="$line"
  fi
done

# Generate an ID from the title
ID=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')

# Escape special characters for JSON
TITLE_ESC=$(echo "$TITLE" | sed 's/"/\\"/g')
VENUE_ESC=$(echo "$VENUE" | sed 's/"/\\"/g')
VENUE_DETAIL_ESC=$(echo "$VENUE_DETAIL" | sed 's/"/\\"/g')
ABSTRACT_ESC=$(echo "$ABSTRACT" | sed 's/"/\\"/g')

# Build the new entry
NEW_ENTRY=$(cat <<JSONEOF
  {
    "id": "$ID",
    "title": "$TITLE_ESC",
    "venue": "$VENUE_ESC",
    "venueDetail": "$VENUE_DETAIL_ESC",
    "year": "$YEAR",
    "sortYear": $SORT_YEAR,
    "type": "$TYPE",
    "selected": $SELECTED,
    "pdf": "papers/$PDF_FILENAME",
    "abstract": "$ABSTRACT_ESC"
  }
JSONEOF
)

# Add to the JSON array (insert after the opening bracket)
# Using python for reliable JSON manipulation
python3 -c "
import json, sys

with open('$DATA_PATH', 'r') as f:
    papers = json.load(f)

new_paper = json.loads('''$NEW_ENTRY''')
papers.insert(0, new_paper)

with open('$DATA_PATH', 'w') as f:
    json.dump(papers, f, indent=2, ensure_ascii=False)

print('Done!')
"

echo ""
echo "=== Paper added successfully! ==="
echo ""
echo "Don't forget to:"
echo "  1. Put '$PDF_FILENAME' in the papers/ folder"
echo "  2. If using GitHub Pages, commit and push your changes"
echo ""
