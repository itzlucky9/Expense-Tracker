import 'package:expense_tracker/db_helper.dart';
import 'package:expense_tracker/history_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _expenses = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  String get formattedDate {
    return "${_selectedDate.year}-"
           "${_selectedDate.month.toString().padLeft(2, '0')}-"
           "${_selectedDate.day.toString().padLeft(2, '0')}";
  }

  Future<void> _addExpense() async {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text);

    if (title.isEmpty || amount == null) return;

    final db = await DBHelper.database;

    await db.insert('expenses', {
      'title': title,
      'amount': amount,
      'date': formattedDate,
    });

    _titleController.clear();
    _amountController.clear();

    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final db = await DBHelper.database;

    final data = await db.query(
      'expenses',
      where: 'date = ?',
      whereArgs: [formattedDate],
    );

    setState(() {
      _expenses = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  double get _totalExpense {
    double total = 0;

    for (var expense in _expenses) {
      total += expense['amount'];
    }
    return total;
  }

  Future<void> _deletExpense(int id) async {
    final db = await DBHelper.database;

    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);

    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            onPressed: () async {
              final selectedDate = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );

              if(selectedDate != null){
                setState(() {
                  _selectedDate = DateTime.parse(selectedDate);
                });
                _loadExpenses();
              }

            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Total Expense: ₹${_totalExpense.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Expense title'),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: _addExpense,
              child: const Text("Add Expense"),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(_expenses[index]['title']),
                      subtitle: Text("₹${_expenses[index]['amount']}"),
                      trailing: IconButton(
                        onPressed: () => _deletExpense(_expenses[index]['id']),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
