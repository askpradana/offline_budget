import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:offline_budget/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'budget_entry.dart';
import 'budget_entry_form.dart';
import 'currency.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Box<BudgetEntry> budgetBox;
  late Currency _selectedCurrency;

  final Color _primaryColor = const Color(0xFF6200EE);
  final Color _accentColor = const Color(0xFF03DAC6);
  final Color _backgroundColor = const Color(0xFFF5F5F5);
  final Color _surfaceColor = Colors.white;
  final Color _textColor = const Color(0xFF1D1D1D);

  @override
  void initState() {
    super.initState();
    budgetBox = Hive.box<BudgetEntry>('budgetBox');
    _selectedCurrency = Currency.availableCurrencies[0];
    _loadCurrency();
  }

  void _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final currencyCode = prefs.getString('currency') ?? 'USD';
    setState(() {
      _selectedCurrency = Currency.getByCode(currencyCode);
    });
  }

  void _showEntryForm({BudgetEntry? entry}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BudgetEntryForm(
              entry: entry,
              currency: _selectedCurrency,
              onSave: (BudgetEntry newEntry) {
                if (entry != null) {
                  entry.description = newEntry.description;
                  entry.amount = newEntry.amount;
                  entry.date = newEntry.date;
                  entry.isExpense = newEntry.isExpense;
                  entry.save();
                } else {
                  budgetBox.add(newEntry);
                }
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  void _deleteEntry(BudgetEntry entry) {
    entry.delete();
    setState(() {});
  }

  double _calculateCurrentBudget() {
    double total = 0;
    for (var i = 0; i < budgetBox.length; i++) {
      final entry = budgetBox.getAt(i);
      if (entry != null) {
        total += entry.isExpense ? -entry.amount : entry.amount;
      }
    }
    return total;
  }

  Map<String, List<BudgetEntry>> _groupEntriesByMonth() {
    Map<String, List<BudgetEntry>> groupedEntries = {};
    List<BudgetEntry> entries = budgetBox.values.toList();
    entries.sort((a, b) => b.date.compareTo(a.date));

    for (var entry in entries) {
      String monthYear = DateFormat('MMMM yyyy').format(entry.date);
      if (!groupedEntries.containsKey(monthYear)) {
        groupedEntries[monthYear] = [];
      }
      groupedEntries[monthYear]!.add(entry);
    }

    return groupedEntries;
  }

  Map<String, Map<String, double>> _calculateMonthlyTotals(
      Map<String, List<BudgetEntry>> groupedEntries) {
    Map<String, Map<String, double>> monthlyTotals = {};

    groupedEntries.forEach((month, entries) {
      double income = 0;
      double expense = 0;

      for (var entry in entries) {
        if (entry.isExpense) {
          expense += entry.amount;
        } else {
          income += entry.amount;
        }
      }

      monthlyTotals[month] = {
        'income': income,
        'expense': expense,
        'balance': income - expense,
      };
    });

    return monthlyTotals;
  }

  String _formatLargeNumber(double number) {
    if (number.abs() >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number.abs() >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number.abs() >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(2);
    }
  }

  Widget _buildMonthlyReportCard(String month, Map<String, double> totals) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            month,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildReportItem(
                      'Income', totals['income']!, Colors.green)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildReportItem(
                      'Expense', totals['expense']!, Colors.red)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildReportItem('Balance', totals['balance']!,
                      totals['balance']! >= 0 ? _accentColor : Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: _textColor.withOpacity(0.6)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${_selectedCurrency.symbol}${_formatLargeNumber(amount)}',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentBudget = _calculateCurrentBudget();
    final groupedEntries = _groupEntriesByMonth();
    final monthlyTotals = _calculateMonthlyTotals(groupedEntries);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              ).then((_) {
                // Refresh the page when returning from settings
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Budget',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedCurrency.format(currentBudget),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: 80), // Add padding at the bottom
              itemCount: groupedEntries.length,
              itemBuilder: (context, index) {
                String month = groupedEntries.keys.elementAt(index);
                List<BudgetEntry> entries = groupedEntries[month]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMonthlyReportCard(month, monthlyTotals[month]!),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entries.length,
                      itemBuilder: (context, entryIndex) {
                        final entry = entries[entryIndex];
                        return Dismissible(
                          key: Key(entry.key.toString()),
                          background: Container(
                            color: Colors.red[400],
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _deleteEntry(entry);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('${entry.description} deleted')),
                            );
                          },
                          child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: _surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: entry.isExpense
                                      ? Colors.red[100]
                                      : Colors.green[100],
                                  child: Icon(
                                    entry.isExpense ? Icons.remove : Icons.add,
                                    color: entry.isExpense
                                        ? Colors.red[700]
                                        : Colors.green[700],
                                  ),
                                ),
                                title: Text(
                                  entry.description,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${entry.isExpense ? "-" : ""}${_selectedCurrency.symbol}${_formatLargeNumber(entry.amount)}',
                                  style: TextStyle(
                                    color: entry.isExpense
                                        ? Colors.red[700]
                                        : Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Text(
                                  DateFormat('MMM d').format(entry.date),
                                  style: TextStyle(
                                      color: _textColor.withOpacity(0.6)),
                                ),
                                onTap: () => _showEntryForm(entry: entry),
                              )),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEntryForm(),
        tooltip: 'Add Entry',
        backgroundColor: _accentColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
