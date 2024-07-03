import 'package:flutter/material.dart';
import 'budget_entry.dart';
import 'currency.dart';

class BudgetEntryForm extends StatefulWidget {
  final BudgetEntry? entry;
  final Currency currency;
  final Function onSave;

  const BudgetEntryForm({
    Key? key,
    this.entry,
    required this.currency,
    required this.onSave,
  }) : super(key: key);

  @override
  _BudgetEntryFormState createState() => _BudgetEntryFormState();
}

class _BudgetEntryFormState extends State<BudgetEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  late bool _isExpense;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.entry?.description ?? '');
    _amountController = TextEditingController(
      text: widget.entry != null ? widget.entry!.amount.toString() : '',
    );
    _selectedDate = widget.entry?.date ?? DateTime.now();
    _isExpense = widget.entry?.isExpense ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: widget.currency.symbol,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Type:'),
              const SizedBox(width: 16),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Income'),
                  selected: !_isExpense,
                  onSelected: (selected) {
                    setState(() {
                      _isExpense = !selected;
                    });
                  },
                  selectedColor: Colors.green[100],
                  labelStyle: TextStyle(
                    color: !_isExpense ? Colors.green[700] : Colors.black,
                    fontWeight:
                        !_isExpense ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Expense'),
                  selected: _isExpense,
                  onSelected: (selected) {
                    setState(() {
                      _isExpense = selected;
                    });
                  },
                  selectedColor: Colors.red[100],
                  labelStyle: TextStyle(
                    color: _isExpense ? Colors.red[700] : Colors.black,
                    fontWeight:
                        _isExpense ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Date'),
            subtitle: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2025),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final entry = BudgetEntry(
                  description: _descriptionController.text,
                  amount: double.parse(_amountController.text),
                  date: _selectedDate,
                  isExpense: _isExpense,
                );
                widget.onSave(entry);
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(widget.entry == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
