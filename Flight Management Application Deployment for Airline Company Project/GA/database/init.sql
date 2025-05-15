CREATE DATABASE IF NOT EXISTS galactic_airlines;
USE galactic_airlines;

CREATE TABLE IF NOT EXISTS flights (
    id INT AUTO_INCREMENT PRIMARY KEY,
    flight_identifier VARCHAR(50),
    departure_location VARCHAR(100),
    destination_location VARCHAR(100),
    scheduled_departure DATETIME,
    scheduled_arrival DATETIME,
    aircraft_model VARCHAR(50),
    seating_capacity INT,
    crew_count INT
);

