import 'package:flutter/material.dart';

void main() {
  runApp(const ExpenseApp());
}

// ─── Model ───────────────────────────────────────────────────────────────────

class Expense {
  final int id;
  String title;
  double amount;

  Expense({required this.id, required this.title, required this.amount});
}

// ─── App ─────────────────────────────────────────────────────────────────────

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFD600)),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ExpenseListScreen(),
        '/add-expense': (context) => const AddEditExpenseScreen(),
        '/edit-expense': (context) => const AddEditExpenseScreen(),
      },
    );
  }
}

// ─── Expense List Screen ──────────────────────────────────────────────────────

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final List<Expense> _expenses = [
    Expense(id: 1, title: 'Grocery Run', amount: 850.00),
    Expense(id: 2, title: 'Netflix Subscription', amount: 199.00),
    Expense(id: 3, title: 'Bus Fare', amount: 45.00),
  ];

  int _nextId = 4;

  double get _total => _expenses.fold(0, (sum, e) => sum + e.amount);

  void _goToAdd() async {
    final result = await Navigator.pushNamed(context, '/add-expense');
    if (!mounted) return;
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _expenses.add(
          Expense(
            id: _nextId++,
            title: result['title'],
            amount: result['amount'],
          ),
        );
      });
    }
  }

  void _goToEdit(Expense expense) async {
    final result = await Navigator.pushNamed(
      context,
      '/edit-expense',
      arguments: expense,
    );
    if (!mounted) return;
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        final index = _expenses.indexWhere((e) => e.id == expense.id);
        if (index != -1) {
          _expenses[index].title = result['title'];
          _expenses[index].amount = result['amount'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD600),
        title: const Text(
          '💰 My Expenses',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF1A1A1A)),
            onPressed: _goToAdd,
          ),
        ],
      ),
      body: Column(
        children: [
          // Total Banner
          Container(
            color: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL SPENT',
                  style: TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '₱${_total.toStringAsFixed(2)}', // 👈 changed
                  style: const TextStyle(
                    color: Color(0xFFFFD600),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _expenses.isEmpty
                ? const Center(
                    child: Text(
                      'No expenses yet.\nTap + to add one!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _expenses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return GestureDetector(
                        onTap: () => _goToEdit(expense),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: const Border(
                              left: BorderSide(
                                color: Color(0xFFFFD600),
                                width: 4,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: 0.07,
                                ), // 👈 fixed
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0
                                          ? const Color(0xFFFFD600)
                                          : const Color(0xFFF9A825),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    expense.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₱${expense.amount.toStringAsFixed(2)}', // 👈 changed
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 17,
                                      color: Color(0xFFE53935),
                                    ),
                                  ),
                                  const Text(
                                    'TAP TO EDIT',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAdd,
        backgroundColor: const Color(0xFFE53935),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// ─── Add / Edit Screen ────────────────────────────────────────────────────────

class AddEditExpenseScreen extends StatefulWidget {
  const AddEditExpenseScreen({super.key});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Expense? _existing;
  bool _initialized = false;

  bool get _isEdit => _existing != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _existing = ModalRoute.of(context)?.settings.arguments as Expense?;
      if (_existing != null) {
        _titleController.text = _existing!.title;
        _amountController.text = _existing!.amount.toString();
      }
      _initialized = true;
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'title': _titleController.text.trim(),
        'amount': double.parse(_amountController.text.trim()),
      });
    }
  }

  void _cancel() {
    Navigator.pop(context, null);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor = _isEdit
        ? const Color(0xFF43A047)
        : const Color(0xFFE53935);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _cancel,
        ),
        title: Text(
          _isEdit ? '✏️ Edit Expense' : '➕ Add Expense',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08), // 👈 fixed
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    const Text(
                      'EXPENSE TITLE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Color(0xFF757575),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText:
                            'e.g. Kape, Bahay, Gym...', // 👈 localized hint
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFFFD600),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFFFD600),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFFFD600),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE53935),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title cannot be empty';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Amount field
                    const Text(
                      'AMOUNT (₱)', // 👈 changed
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Color(0xFF757575),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFFFD600),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFFFD600),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFFFD600),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE53935),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Amount cannot be empty';
                        }
                        final num = double.tryParse(value.trim());
                        if (num == null || num <= 0) {
                          return 'Enter a valid amount greater than 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _cancel,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(
                                color: Color(0xFF1A1A1A),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appBarColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: Text(
                              _isEdit ? '✓ Update' : '✓ Save',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Navigation info box
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFD600), width: 2),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🗺  NAVIGATION INFO',
                      style: TextStyle(
                        color: Color(0xFFFFD600),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _infoRow(
                      'Route',
                      _isEdit ? '/edit-expense' : '/add-expense',
                    ),
                    _infoRow(
                      'Arguments',
                      _isEdit ? 'Expense(id:${_existing?.id})' : 'none',
                    ),
                    _infoRow('Returns', 'Map<String,dynamic> | null'),
                    _infoRow(
                      'Mode',
                      _isEdit ? 'Edit (prefilled)' : 'Add (empty)',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: Color(0xFFCCCCCC),
          ),
          children: [
            TextSpan(
              text: '$key: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
