import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'budget_entry.dart';
import 'currency.dart';

class SettingsPage extends StatelessWidget {
  final Color _primaryColor = const Color(0xFF6200EE);

  SettingsPage({super.key});

  Future<void> _resetAllData(BuildContext context) async {
    final confirmReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
            'Are you sure you want to reset all data? This action cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Reset'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmReset == true) {
      final budgetBox = Hive.box<BudgetEntry>('budgetBox');
      await budgetBox.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.of(context)
          .pushNamedAndRemoveUntil('/welcome', (Route<dynamic> route) => false);
    }
  }

  Future<void> _exportData(BuildContext context) async {
    final budgetBox = Hive.box<BudgetEntry>('budgetBox');
    final List<Map<String, dynamic>> exportData = budgetBox.values
        .map((entry) => {
              'description': entry.description,
              'amount': entry.amount,
              'date': entry.date.toIso8601String(),
              'isExpense': entry.isExpense,
            })
        .toList();

    final String jsonData = jsonEncode(exportData);

    try {
      if (Platform.isAndroid || kIsWeb) {
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Please select an output file:',
          fileName:
              'budget_data_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json',
        );

        if (outputFile != null) {
          final File file = File(outputFile);
          await file.writeAsString(jsonData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Data exported successfully to $outputFile')),
          );
        }
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        final String fileName =
            'budget_data_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';
        final String filePath = '${directory.path}/$fileName';
        final File file = File(filePath);
        await file.writeAsString(jsonData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported successfully to $filePath')),
        );

        // Show a dialog with the file path
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Successful'),
            content: Text(
                'File saved to:\n$filePath\n\nYou can access this file using the Files app on your device.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting data: ${e.toString()}')),
      );
    }
  }

  Future<void> _importData(BuildContext context) async {
    String? jsonData;

    try {
      if (Platform.isAndroid || kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (result != null) {
          File file = File(result.files.single.path!);
          jsonData = await file.readAsString();
        }
      } else if (Platform.isIOS) {
        // For iOS, we'll show a dialog explaining how to import
        bool? shouldProceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Data'),
            content: const Text(
                'To import data on iOS:\n\n1. Open the Files app\n2. Locate your JSON file\n3. Tap on the file to open it\n4. Choose "Copy to [Your App Name]"\n5. Return to this app and tap "Proceed" below'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Proceed'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );

        if (shouldProceed == true) {
          // After user confirmation, check for new files in the app's documents directory
          final directory = await getApplicationDocumentsDirectory();
          final files = directory.listSync();
          final jsonFiles =
              files.where((file) => file.path.endsWith('.json')).toList();

          if (jsonFiles.isNotEmpty) {
            // Sort files by modification time, most recent first
            jsonFiles.sort((a, b) =>
                b.statSync().modified.compareTo(a.statSync().modified));
            final latestFile = jsonFiles.first;
            jsonData = await File(latestFile.path).readAsString();
          } else {
            throw Exception('No JSON files found in the app\'s directory');
          }
        }
      }

      if (jsonData != null && jsonData.isNotEmpty) {
        final List<dynamic> decodedData = jsonDecode(jsonData);
        final budgetBox = Hive.box<BudgetEntry>('budgetBox');
        await budgetBox.clear(); // Clear existing data before import
        for (var entryData in decodedData) {
          final newEntry = BudgetEntry(
            description: entryData['description'],
            amount: entryData['amount'],
            date: DateTime.parse(entryData['date']),
            isExpense: entryData['isExpense'],
          );
          await budgetBox.add(newEntry);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing data: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: _primaryColor,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Reset All Data'),
            subtitle: const Text('Delete all entries and settings'),
            onTap: () => _resetAllData(context),
          ),
          ListTile(
            title: const Text('Export Data'),
            subtitle: const Text('Save your data as JSON file'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            title: const Text('Import Data'),
            subtitle: const Text('Load data from JSON file'),
            onTap: () => _importData(context),
          ),
        ],
      ),
    );
  }
}
