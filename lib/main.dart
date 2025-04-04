import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truck_v2/firebase_options.dart';
import 'truck_expense_page.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        cardColor: Colors.grey[900],
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.grey),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<DocumentSnapshot> _trucks = [];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('trucks').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          setState(() {
            _trucks.insert(change.newIndex, change.doc);
            _listKey.currentState?.insertItem(change.newIndex);
          });
        } else if (change.type == DocumentChangeType.removed) {
          setState(() {
            final removedTruck = _trucks.removeAt(change.oldIndex);
            _listKey.currentState?.removeItem(
              change.oldIndex,
              (context, animation) => _buildTruckCard(removedTruck, animation),
            );
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Truck List')),
      body: AnimatedList(
        key: _listKey,
        padding: const EdgeInsets.all(16.0),
        initialItemCount: _trucks.length,
        itemBuilder: (context, index, animation) {
          return _buildTruckCard(_trucks[index], animation);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTruckDialog(context),
        label: Row(
          children: const [
            Icon(Icons.add),
            SizedBox(width: 4),
            Text(
              'Add Truck',
              style: TextStyle(
                fontSize: 12,
                color: Color.fromRGBO(230, 224, 233, 1.0),
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTruckCard(DocumentSnapshot truck, Animation<double> animation) {
    final truckId = truck.id;
    return SizeTransition(
      sizeFactor: animation,
      child: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('trucks')
            .doc(truckId)
            .collection('expenses')
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final trips = snapshot.data!.docs;
          double totalDistance = 0;
          double totalExpenses = 0;
          double totalFuelConsumed = 0;

          for (var trip in trips) {
            totalDistance += (trip['totalKm'] ?? 0).toDouble();
            totalExpenses += (trip['totalProfit'] ?? 0).toDouble();
            totalFuelConsumed += (trip['diesel'] ?? 0).toDouble();
          }

          final averageMileage = totalFuelConsumed > 0 ? totalDistance / totalFuelConsumed : 0.0;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              
              border: Border.all(color: Colors.grey.withOpacity(0.4)),
              
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              truck['number'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.map, color: Colors.grey, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Distance: ${totalDistance.toStringAsFixed(2)} km',
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.attach_money, color: Colors.grey, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Expenses: ₹${totalExpenses.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.speed, color: Colors.grey, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Avg Mileage: ${averageMileage.toStringAsFixed(2)} km/L',
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TruckExpensePage(truckId: truckId),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'View Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddTruckDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Truck'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter Truck Number'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final truckNumber = controller.text.trim().toUpperCase();
                final isValidTruckNumber = RegExp(r'^[A-Z]{2}\d{2}[A-Z]{2}\d{4}$').hasMatch(truckNumber);

                if (truckNumber.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Truck number cannot be empty')),
                  );
                } else if (!isValidTruckNumber) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid truck number format')),
                  );
                } else {
                  FirebaseFirestore.instance
                      .collection('trucks')
                      .doc(truckNumber)
                      .set({'number': truckNumber});
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
