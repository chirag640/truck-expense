import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_expense_page.dart';

class TruckExpensePage extends StatefulWidget {
  final String truckId;

  const TruckExpensePage({super.key, required this.truckId});

  @override
  _TruckExpensePageState createState() => _TruckExpensePageState();
}

class _TruckExpensePageState extends State<TruckExpensePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truck Expenses' , style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            _buildSearchBar(),
            _buildMonthlyReport(),
            Expanded(child: _buildTripList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpensePage(truckId: widget.truckId),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search trips...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildMonthlyReport() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trucks')
          .doc(widget.truckId)
          .collection('expenses')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final expenses = snapshot.data!.docs;
        double totalProfit = 0;
        for (var expense in expenses) {
          totalProfit += (expense['totalProfit'] ?? 0).toDouble();
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Report',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Profit: ₹${totalProfit.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This report is calculated based on all trips.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTripList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trucks')
          .doc(widget.truckId)
          .collection('expenses')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final expenses = snapshot.data!.docs.where((doc) {
          final fromPlace = doc['from'].toString().toLowerCase();
          final toPlace = doc['to'].toString().toLowerCase();
          return fromPlace.contains(_searchQuery) || toPlace.contains(_searchQuery);
        }).toList();

        if (expenses.isEmpty) {
          return const Center(
            child: Text(
              'No trips found.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return _buildTripCard(expense);
          },
        );
      },
    );
  }

  Widget _buildTripCard(QueryDocumentSnapshot expense) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trip #${expense['from']} - ${expense['to']}',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${expense['startDate']} - ${expense['endDate']}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From: ${expense['from']}',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        'To: ${expense['to']}',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        'Distance: ${expense['totalKm']} km',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        'Diesel: ${expense['diesel']}L (₹${expense['dieselAmount']})',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        'Mileage: ${(expense['totalKm'] > 0 && expense['diesel'] > 0) ? (expense['totalKm'] / expense['diesel']).toStringAsFixed(2) : 'N/A'} km/L',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Toll Charges: ₹${expense['toll']}',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        'Driver Salary: ₹${expense['driverSalary']}',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        'Maintenance: ₹${expense['maintenance']}',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        'Freight: ${expense['weight']} kg',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Expenses: ₹${expense['totalProfit']}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  expense['totalProfit'] < 0
                      ? 'Loss: ₹${expense['totalProfit'].abs()}'
                      : 'Profit: ₹${expense['totalProfit']}',
                  style: TextStyle(
                    color: expense['totalProfit'] < 0 ? Colors.red : Colors.green,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
