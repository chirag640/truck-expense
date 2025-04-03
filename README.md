# Truck Expense Management Application

A Flutter-based application to manage truck expenses efficiently. This app allows users to track trips, calculate expenses, and monitor profits or losses for each truck.

## Features

- **Truck Management**: Add and view a list of trucks.
- **Expense Tracking**: Add detailed expenses for each trip, including diesel, toll charges, driver salary, maintenance, and freight.
- **Profit/Loss Calculation**: Automatically calculate profit or loss for each trip.
- **Search Functionality**: Search trips by "from" or "to" locations.
- **Monthly Report**: View a summary of total profit or loss for all trips in a month.
- **Responsive Design**: The app is designed to look great on all screen sizes.

## Screenshots

### Home Screen
Displays a list of trucks with total distance traveled and expenses.

### Truck Expense Page
Shows detailed trip expenses for a selected truck.

### Add Expense Page
Allows users to add a new trip expense with all necessary details.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/chirag640/truck-expense-management.git
   ```
2. Navigate to the project directory:
   ```bash
   cd truck-expense-management
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Firebase Configuration

This app uses Firebase for backend services. Ensure you have configured Firebase for your project:

1. Set up a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. Add your Android and iOS apps to the Firebase project.
3. Replace the `firebase_options.dart` file with your Firebase configuration.

## Dependencies

- **Flutter**: The app is built using Flutter.
- **Firebase**: Used for backend services like Firestore.
- **Cloud Firestore**: For storing truck and expense data.

## How to Use

1. **Add a Truck**: Click the "+" button on the home screen to add a new truck.
2. **View Truck Details**: Click on a truck to view its trip expenses.
3. **Add Expense**: Click the "+" button on the truck expense page to add a new trip expense.
4. **Search Trips**: Use the search bar to find trips by "from" or "to" locations.
5. **View Monthly Report**: Check the monthly report section for a summary of profits or losses.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author

Developed by Chirag. For any queries, feel free to reach out at Chaudharychirag640@gmail.com.
