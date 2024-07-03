import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'budget_entry.dart';
import 'currency.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  late Currency _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _selectedCurrency =
        Currency.availableCurrencies[0]; // Initialize with the first currency
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'Budget Tracker')),
    );
  }

  void _saveInitialBudget() async {
    if (_formKey.currentState!.validate()) {
      final budgetBox = Hive.box<BudgetEntry>('budgetBox');
      final initialBudget = double.parse(_budgetController.text);

      budgetBox.add(BudgetEntry(
        description: 'Initial Budget',
        amount: initialBudget,
        date: DateTime.now(),
        isExpense: false,
      ));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstLaunch', false);
      await prefs.setString('currency', _selectedCurrency.code);

      _navigateToHome(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueGrey.shade300, Colors.blueGrey.shade700],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.account_balance_wallet,
                    size: 80, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to Budget Tracker',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Let\'s start by setting your currency and current budget',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                DropdownButtonFormField<Currency>(
                  value: _selectedCurrency,
                  items: Currency.availableCurrencies.map((Currency currency) {
                    return DropdownMenuItem<Currency>(
                      value: currency,
                      child: Text('${currency.code} (${currency.symbol})'),
                    );
                  }).toList(),
                  onChanged: (Currency? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCurrency = newValue;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Currency',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white70),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.blueGrey[700],
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Current Budget',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon:
                          const Icon(Icons.attach_money, color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current budget';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveInitialBudget,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blueGrey[800],
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Start Tracking'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }
}
