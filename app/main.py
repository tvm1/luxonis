#!/usr/bin/python3

import requests

from flask import Flask, render_template
import psycopg2

app = Flask(__name__)

db_config = {
    'dbname': 'mydatabase',
    'user': 'myuser',
    'password': '123',
    'host': 'localhost',
    'port': '5432',
}

@app.route('/')
def index():
    # Connect to the database
    conn = psycopg2.connect(**db_config)
    cur = conn.cursor()

    # Example query to retrieve data
    cur.execute("SELECT name, image FROM mytable")

    # Fetch all rows
    rows = cur.fetchall()

    # Close the database connection
    cur.close()
    conn.close()

    # Render the template with the retrieved data
    return render_template('index.html', rows=rows)

if __name__ == '__main__':
    url = "https://www.sreality.cz/api/cs/v2/estates?category_main_cb=1&category_type_cb=1&page=0&per_page=10"

    print("Populating database")

    # Make a GET request to the URL
    response = requests.get(url)

    # Check if the request was successful (status code 200)
    if response.status_code == 200:
        # Unpack JSON content from the response
        json_data = response.json()

        # Now you can work with the unpacked JSON data
        print("Unpacked JSON data:")

        for entry in json_data['_embedded']['estates']:
            name = (entry['name'] + " - " + entry['locality'])
            image_url = (entry['_links']['images'][0].get('href'))
            print(f"{name} - {image_url}")

            conn = psycopg2.connect(
                host='localhost',
                user='myuser',
                password='123',
                database='mydatabase'
            )

            cur = conn.cursor()

            # Insert data into the table
            cur.execute("INSERT INTO mytable (name, image) VALUES (%s, %s)", (name, image_url))

            # Commit the transaction and close the connection
            conn.commit()
            cur.close()
            conn.close()


    app.run(host='0.0.0.0', port=8080, debug=True)

