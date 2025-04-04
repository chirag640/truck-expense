import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AddExpensePage extends StatefulWidget {
  final String truckId;

  const AddExpensePage({super.key, required this.truckId});

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final TextEditingController _startKmController = TextEditingController();
  final TextEditingController _endKmController = TextEditingController();
  final TextEditingController _freightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Expense', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 10, // Add shadow effect
        shape: const RoundedRectangleBorder( // Add custom shape
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Trip Details'),
                _buildCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              label: 'Start Date',
                              controller: _startDateController,
                              isStartDate: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateField(
                              label: 'End Date',
                              controller: _endDateController,
                              isStartDate: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'From Location',
                              onSaved: (value) => _formData['from'] = value!,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'To Location',
                              onSaved: (value) => _formData['to'] = value!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Distance Details'),
                _buildCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Start KM',
                          controller: _startKmController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _calculateTotalKm(),
                          onSaved: (value) => _formData['startKm'] = int.parse(value!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'End KM',
                          controller: _endKmController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _calculateTotalKm(),
                          onSaved: (value) => _formData['endKm'] = int.parse(value!),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Expense Details'),
                _buildCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Diesel Quantity (L)',
                              keyboardType: TextInputType.number,
                              onSaved: (value) => _formData['diesel'] = int.parse(value!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Diesel Cost (₹)',
                              keyboardType: TextInputType.number,
                              onSaved: (value) => _formData['dieselAmount'] = double.parse(value!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Toll Charges (₹)',
                              keyboardType: TextInputType.number,
                              onSaved: (value) => _formData['toll'] = double.parse(value!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Driver Salary (₹)',
                              keyboardType: TextInputType.number,
                              onSaved: (value) => _formData['driverSalary'] = double.parse(value!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Maintenance Cost (₹)',
                              keyboardType: TextInputType.number,
                              onSaved: (value) => _formData['maintenance'] = double.parse(value!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Freight Cost (₹)',
                              controller: _freightController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _calculateTotalFreight(),
                              onSaved: (value) => _formData['freight'] = double.parse(value!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Freight Weight (kg)',
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotalFreight(),
                        onSaved: (value) => _formData['weight'] = double.parse(value!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _addExpense();
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit Expense',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required bool isStartDate,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.white),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        fillColor: Colors.grey[800],
        filled: true,
      ),
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      onTap: () => _selectDate(context, isStartDate: isStartDate),
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        fillColor: Colors.grey[800],
        filled: true,
      ),
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      onSaved: onSaved,
      // Removed the dynamic `enabled` property to always allow input
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDateController.text = pickedDate.toIso8601String().split('T').first;
        } else {
          _endDateController.text = pickedDate.toIso8601String().split('T').first;
        }
      });
    }
  }

  void _calculateTotalKm() {
    final startKm = int.tryParse(_startKmController.text) ?? 0;
    final endKm = int.tryParse(_endKmController.text) ?? 0;
    setState(() {
      _formData['totalKm'] = endKm - startKm;
    });
  }

  void _calculateTotalFreight() {
    final freight = double.tryParse(_freightController.text) ?? 0.0;
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    setState(() {
      _formData['totalFreight'] = freight * weight;
    });
  }

  void _addExpense() {
    final uuid = Uuid();
    final id = uuid.v4();
    final totalProfit = _calculateProfit();
    FirebaseFirestore.instance
        .collection('trucks')
        .doc(widget.truckId)
        .collection('expenses')
        .doc(id)
        .set({
      'id': id,
      'truckId': widget.truckId,
      'startDate': _startDateController.text,
      'endDate': _endDateController.text,
      ..._formData,
      'totalProfit': totalProfit,
    });
  }

  double _calculateProfit() {
    final totalFreight = _formData['totalFreight'] ?? 0.0;
    final dieselAmount = _formData['dieselAmount'] ?? 0.0;
    final toll = _formData['toll'] ?? 0.0;
    final driverSalary = _formData['driverSalary'] ?? 0.0;
    final maintenance = _formData['maintenance'] ?? 0.0;

    return totalFreight - (dieselAmount + toll + driverSalary + maintenance);
  }
}
