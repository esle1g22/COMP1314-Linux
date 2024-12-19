#!/bin/bash

# MySQL credentials
DB_USER="root"
DB_PASSWORD=""  # Replace with your MySQL root password
DB_NAME="crypto_db"

# Arrays for currency names and their URLs
CURRENCIES=("bitcoin" "ethereum" "litecoin" "avalanche" "bnb" "chainlink" "solana" "toncoin" "xrp" "sui")
URLS=(
    "https://coinmarketcap.com/currencies/bitcoin/"
    "https://coinmarketcap.com/currencies/ethereum/"
    "https://coinmarketcap.com/currencies/litecoin/"
    "https://coinmarketcap.com/currencies/avalanche/"
    "https://coinmarketcap.com/currencies/bnb/"
    "https://coinmarketcap.com/currencies/chainlink/"
    "https://coinmarketcap.com/currencies/solana/"
    "https://coinmarketcap.com/currencies/toncoin/"
    "https://coinmarketcap.com/currencies/xrp/"
    "https://coinmarketcap.com/currencies/sui/"
)

# Temporary file for storing webpage
TEMP_FILE="crypto_page.html"

# Function to fetch price
fetch_PRICE() {
    local currency_name=$1
    local currency_url=$2

    echo "Fetching $currency_name price from CoinMarketCap..."
    curl -s "$currency_url" -o "$TEMP_FILE"

    # Check if curl command succeeded
    if [ $? -ne 0 ]; then
        echo "Error: Failed to fetch webpage for $currency_name. Check network connection or website availability."
        return 1
    fi

    echo "Parsing $currency_name price..."

    # Dynamic grep pattern based on currency
    if [ "$currency_name" == "bitcoin" ]; then
        PRICE=$(grep -o '<span class="sc-65e7f566-0 esyGGG base-text" data-test="text-cdp-price-display">\$[0-9,]*\.[0-9]*</span>' "$TEMP_FILE" | \
            sed -E 's/.*>\$([0-9,]*\.[0-9]*).*/\1/;s/,//g')
    else
        PRICE=$(grep -o '<span class="sc-65e7f566-0 WXGwg base-text" data-test="text-cdp-price-display">\$[0-9,]*\.[0-9]*</span>' "$TEMP_FILE" | \
            sed -E 's/.*>\$([0-9,]*\.[0-9]*).*/\1/;s/,//g')
    fi

    CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')

    if [ -z "$PRICE" ]; then
        echo "Error: Failed to parse $currency_name price. Webpage structure might have changed."
        # Debugging: Output the relevant HTML snippet
        echo "Debugging: HTML snippet for $currency_name"
        grep -o '<span.*</span>' "$TEMP_FILE" | head -n 10
        return 1
    fi

    echo "Parsed Price for $currency_name: $PRICE"
    echo "Parsed Time: $CURRENT_TIME"
}

# Function to insert data into MySQL
insert_data() {
    local currency_name=$1

    echo "Inserting data for $currency_name into $DB_NAME.$currency_name..."
    /Applications/XAMPP/xamppfiles/bin/mysql -u "$DB_USER" "$DB_NAME" \
    -e "INSERT INTO \`$currency_name\` (Price, Time) VALUES ($PRICE, '$CURRENT_TIME');"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to insert data for $currency_name into the database."
        return 1
    fi

    echo "Data for $currency_name successfully inserted into the database."
}

# Cleanup function
cleanup() {
    echo "Cleaning up temporary files..."
    rm -f "$TEMP_FILE"
}

# Main script logic
for i in "${!CURRENCIES[@]}"; do
    currency_name=${CURRENCIES[$i]}
    currency_url=${URLS[$i]}
    fetch_PRICE "$currency_name" "$currency_url" && insert_data "$currency_name"
done

cleanup

echo "Script execution completed successfully for all currencies."