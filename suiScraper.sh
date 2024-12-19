#!/bin/bash

# MySQL credentials
DB_USER="root"
DB_PASSWORD=""  # Replace with your MySQL root password
DB_NAME="crypto_db"
TABLE_NAME="sui"

# CoinMarketCap URL
SUI_URL="https://coinmarketcap.com/currencies/sui/"

# Temporary file for storing webpage
TEMP_FILE="sui_page.html"

# Function to fetch price
fetch_PRICE() {
    echo "Fetching Sui price from CoinMarketCap..."
    curl -s "$SUI_URL" -o "$TEMP_FILE"

    # Check if curl command succeeded
    if [ $? -ne 0 ]; then
        echo "Error: Failed to fetch webpage. Check network connection or website availability."
        exit 1
    fi

    echo "Parsing Sui price..."
    
   # Extract the price using grep and awk for the updated structure
    PRICE=$(grep -o '<span class="sc-65e7f566-0 WXGwg base-text" data-test="text-cdp-price-display">\$[0-9,]*\.[0-9]*</span>' "$TEMP_FILE" | \
        awk -F '</span>' '{print $1}' | \
        sed 's/.*>\$//;s/,//g')
        
    # Extract the current date and time
    CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')

    if [ -z "$PRICE" ]; then
        echo "Error: Failed to parse Sui price. Webpage structure might have changed."
        exit 1
    fi

    echo "Parsed Price: $PRICE"
    echo "Parsed Time: $CURRENT_TIME"
}

# Function to insert data into MySQL
insert_data() {
    echo "Inserting data into $DB_NAME.$TABLE_NAME..."
    /Applications/XAMPP/xamppfiles/bin/mysql -u "$DB_USER" "$DB_NAME" \
    -e "INSERT INTO $TABLE_NAME (Price, Time) VALUES ($PRICE, '$CURRENT_TIME');"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to insert data into the database."
        exit 1
    fi

    echo "Data successfully inserted into the database."
}

# Cleanup function
cleanup() {
    echo "Cleaning up temporary files..."
    rm -f "$TEMP_FILE"
}

# Main script logic
fetch_PRICE
insert_data
cleanup

echo "Script execution completed successfully."