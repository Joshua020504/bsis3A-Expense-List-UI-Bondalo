import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Navigator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFD600)),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      home: const ExpensesHomePage(),
    );
  }
}

// ─── Screen 1: Home ───────────────────────────────────────────────────────────

class ExpensesHomePage extends StatefulWidget {
  const ExpensesHomePage({super.key});

  @override
  State<ExpensesHomePage> createState() => _ExpensesHomePageState();
}

class _ExpensesHomePageState extends State<ExpensesHomePage> {
  final List<String> _expenses = [];

  void _goToAddExpense() async {
    final title = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpensePage()),
    );

    if (!mounted) return;
    if (title != null && title is String) {
      setState(() {
        _expenses.add(title);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added: $title'),
          backgroundColor: const Color(0xFF43A047),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _deleteExpense(int index) {
    final deleted = _expenses[index];
    setState(() {
      _expenses.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted: $deleted'),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: const Color(0xFFFFD600),
          onPressed: () {
            setState(() {
              _expenses.insert(index, deleted);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD600),
        title: const Text(
          '💰 Expenses Home',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _goToAddExpense,
            icon: const Icon(Icons.add, color: Color(0xFF1A1A1A)),
            label: const Text(
              '+ Add',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: _expenses.isEmpty
          ? const Center(
              child: Text(
                'No expenses yet.\nTap "+ Add" to get started!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _expenses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return Dismissible(
                  // Swipe left to delete
                  key: Key(_expenses[index] + index.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _deleteExpense(index),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, color: Colors.white, size: 26),
                        SizedBox(height: 4),
                        Text(
                          'DELETE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(
                        left: BorderSide(color: Color(0xFFFFD600), width: 4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
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
                      children: [
                        // Number badge
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD600),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title
                        Expanded(
                          child: Text(
                            _expenses[index],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        // Delete icon button
                        IconButton(
                          onPressed: () => _deleteExpense(index),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFE53935),
                          ),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddExpense,
        backgroundColor: const Color(0xFFE53935),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// ─── Screen 2: Add Expense ────────────────────────────────────────────────────

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _titleController = TextEditingController();
  bool _showError = false;

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    Navigator.pop(context, title);
  }

  void _cancel() {
    Navigator.pop(context, null);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _cancel,
        ),
        title: const Text(
          '➕ Add Expense',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD600), width: 2),
              ),
              padding: const EdgeInsets.all(14),
              child: const Text(
                '📌  Navigator.pop(context, title)\nwill send the title back to Home.',
                style: TextStyle(
                  color: Color(0xFFFFD600),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 24),

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

            TextField(
              controller: _titleController,
              autofocus: true,
              onChanged: (_) {
                if (_showError) setState(() => _showError = false);
              },
              decoration: InputDecoration(
                hintText: 'e.g. Kape, Ulam, Load...',
                filled: true,
                fillColor: Colors.white,
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
            ),

            if (_showError) ...[
              const SizedBox(height: 6),
              const Text(
                '⚠️  Title cannot be empty.',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 24),

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
                      backgroundColor: const Color(0xFFE53935),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      '✓ Save',
                      style: TextStyle(
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
    );
  }
}
