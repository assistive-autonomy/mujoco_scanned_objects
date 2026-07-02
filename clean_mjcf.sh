#!/bin/bash

# Check if an input file was provided
if [ -z "$1" ]; then
    echo "Usage: $0 path/to/model.xml"
    exit 1
fi

INPUT_FILE="$1"
DIR_NAME=$(dirname "$INPUT_FILE")
OUTPUT_MODEL_FILE="$DIR_NAME/model_clean.xml"
OUTPUT_ASSETS_FILE="$DIR_NAME/assets.xml"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found."
    exit 1
fi

echo "<mujoco model=\"${DIR_NAME}_model\">" > "$OUTPUT_MODEL_FILE"
echo "<mujoco model=\"${DIR_NAME}_assets\">" > "$OUTPUT_ASSETS_FILE"

echo "Processing $INPUT_FILE..."

# 1. Use sed to extract only the text between <body> and </body> (inclusive)
# 2. Rename the body name to avoid potential naming conflicts down the line
# 3. Add a <freejoint/> right under the <body> tag so it can interact with the physics engine
sed -n '/<body/,/\/body>/p' "$INPUT_FILE" | \
sed 's/<body name="model">/<body name="scanned_object">/g' >> "$OUTPUT_MODEL_FILE"
echo "</mujoco>" >> "$OUTPUT_MODEL_FILE"

# | \ sed 's/\(<body name="scanned_object">\)/\1\n      <freejoint name="object_joint"\/>/' > "$OUTPUT_FILE"

sed -n '/<asset/,/\/asset>/p' "$INPUT_FILE" | \
sed 's/<body name="model">/<body name="scanned_object">/g' >> "$OUTPUT_ASSETS_FILE"
echo "</mujoco>" >> "$OUTPUT_ASSETS_FILE"

if [ $? -eq 0 ]; then
    echo "Success! Clean snippets saved to: $OUTPUT_MODEL_FILE and $OUTPUT_ASSETS_FILE"
else
    echo "Error processing file."
fi