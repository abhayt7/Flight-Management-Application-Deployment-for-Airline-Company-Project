// Replace with the correct backend URL
const backendURL = "http://backend-service:5000"; // ELB URL for backend

// Function to add a flight
function addFlight() {
    const data = {
        flight_identifier: document.getElementById('flightIdentifier').value,
        departure_location: document.getElementById('departureLocation').value,
        destination_location: document.getElementById('destinationLocation').value,
        scheduled_departure: document.getElementById('scheduledDeparture').value,
        scheduled_arrival: document.getElementById('scheduledArrival').value,
        aircraft_model: document.getElementById('aircraftModel').value,
        seating_capacity: document.getElementById('seatingCapacity').value,
        crew_count: document.getElementById('crewCount').value
    };

    fetch("http://www.tellus.quest/api/add_flight", {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(data => alert(data.message))
    .catch(error => console.error('Error:', error));
}

// Function to delete a flight
function deleteFlight() {
    const flightId = document.getElementById('deleteFlightId').value;

    fetch("http://www.tellus.quest/api/delete_flight/${flightId}", {
        method: 'DELETE'
    })
    .then(response => response.json())
    .then(data => alert(data.message))
    .catch(error => console.error('Error:', error));
}

// Function to fetch and display all flights
function fetchFlights() {
    fetch("http://www.tellus.quest/api/fetch_flights")
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        const flightsTable = document.getElementById('flightsTable');

        if (data.length === 0) {
            flightsTable.innerHTML = "<p>No flights available.</p>";
            return;
        }

        let tableHTML = "<table><tr><th>ID</th><th>Departure</th><th>Destination</th><th>Departure Time</th><th>Arrival Time</th><th>Model</th><th>Seats</th><th>Crew</th></tr>";
        data.forEach(flight => {
            tableHTML += `<tr><td>${flight.flight_identifier}</td><td>${flight.departure_location}</td><td>${flight.destination_location}</td><td>${flight.scheduled_departure}</td><td>${flight.scheduled_arrival}</td><td>${flight.aircraft_model}</td><td>${flight.seating_capacity}</td><td>${flight.crew_count}</td></tr>`;
        });
        tableHTML += "</table>";
        flightsTable.innerHTML = tableHTML;
    })
    .catch(error => {
        console.error('Error:', error);
        document.getElementById('flightsTable').innerText = 'Error fetching flight data. Please try again later.';
    });
}
