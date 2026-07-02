#!/bin/bash

# Path to your main models folder containing the 1,000 subfolders
TARGET_DIR="models/"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' not found."
    exit 1
fi

echo "Bulk processing object subfolders inside '$TARGET_DIR'..."

# -execdir runs the script snippet directly inside the directory where model.xml is found.
# This makes "." always represent the individual object folder (e.g. ACE_Coffee_Mug_Kristen_16_oz_cup)
find "$TARGET_DIR" -type f -name "model.xml" | while read -r INPUT_FILE; do
    # Extract the current folder name cleanly
    DIR_NAME=$(dirname "$INPUT_FILE")
    FOLDER_NAME=$(basename "$DIR_NAME")
    OUTPUT_MODEL_FILE="$DIR_NAME/model_clean.xml"
    OUTPUT_ASSETS_FILE="$DIR_NAME/assets.xml"
    
    echo "Processing: $FOLDER_NAME"

    # Check if input file exists
    if [ ! -f "$INPUT_FILE" ]; then
        echo "Error: File '$INPUT_FILE' not found."
        exit 1
    fi

    echo "<mujoco model=\"${FOLDER_NAME}_model\">" > "$OUTPUT_MODEL_FILE"
    # 1. Extract body content
    # 2. Assign the unique folder name to the body block
    sed -n '/<body/,/\/body>/p' "$INPUT_FILE" | \
    sed 's/<body name="model">/<body name="scanned_object">/g' >> "$OUTPUT_MODEL_FILE"
    echo "</mujoco>" >> "$OUTPUT_MODEL_FILE"

    echo "<mujoco model=\"${FOLDER_NAME}_assets\">" > "$OUTPUT_ASSETS_FILE"
    sed -n '/<asset/,/\/asset>/p' "$INPUT_FILE" | \
    sed 's/<body name="model">/<body name="scanned_object">/g' >> "$OUTPUT_ASSETS_FILE"
    echo "</mujoco>" >> "$OUTPUT_ASSETS_FILE"
done

echo "------------------------------------------------"
echo "Done! Generated model_clean.xml across your dataset folders."