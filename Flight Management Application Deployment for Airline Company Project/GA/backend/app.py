import logging
import traceback
from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector

logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__)

# Enable CORS for all origins
CORS(app, resources={r"/*": {"origins": "*"}})  # Allow all origins

@app.route('/')
def index():
    return "Backend service is running", 200

# Route to add a flight
@app.route('/add_flight', methods=['POST'])
def add_flight():
    try:
        data = request.get_json()

        # Connect to the database
        conn = mysql.connector.connect(
            host="database-service",
            user="root",
            password="password",
            database="galactic_airlines"
        )
        cursor = conn.cursor()

        # Insert flight details into the database
        cursor.execute("""
            INSERT INTO flights (flight_identifier, departure_location, destination_location,
            scheduled_departure, scheduled_arrival, aircraft_model, seating_capacity, crew_count)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            data['flight_identifier'],
            data['departure_location'],
            data['destination_location'],
            data['scheduled_departure'],
            data['scheduled_arrival'],
            data['aircraft_model'],
            data['seating_capacity'],
            data['crew_count']
        ))

        conn.commit()  # Commit the transaction
        cursor.close()
        conn.close()

        return jsonify({"status": "success", "message": "Flight added successfully"}), 200

    except Exception as e:
        logging.error("Error in /add_flight: %s", traceback.format_exc())
        return jsonify({"status": "error", "message": str(e)}), 500

# Route to fetch flights
@app.route('/fetch_flights', methods=['GET'])
def fetch_flights():
    try:
        # Connect to the database
        conn = mysql.connector.connect(
            host="database-service",
            user="root",
            password="password",
            database="galactic_airlines"
        )
        cursor = conn.cursor(dictionary=True)

        # Fetch all flights from the database
        cursor.execute("SELECT * FROM flights")
        flights = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify(flights), 200

    except Exception as e:
        logging.error("Error in /fetch_flights: %s", traceback.format_exc())
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/delete_flight/<flight_id>', methods=['DELETE'])
def delete_flight(flight_id):
    try:
        # Connect to the database
        conn = mysql.connector.connect(
            host="database-service",
            user="root",
            password="password",
            database="galactic_airlines"
        )
        cursor = conn.cursor()

        # Execute deletion query
        cursor.execute("DELETE FROM flights WHERE flight_identifier = %s", (flight_id,))
        conn.commit()

        cursor.close()
        conn.close()

        if cursor.rowcount > 0:
            return jsonify({"status": "success", "message": "Flight deleted successfully"}), 200
        else:
            return jsonify({"status": "error", "message": "Flight not found"}), 404

    except Exception as e:
        logging.error("Error in /delete_flight: %s", traceback.format_exc())
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
