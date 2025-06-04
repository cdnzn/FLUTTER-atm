import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Denzon & Babala ATM',
      home: PinEntryScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PinEntryScreen extends StatefulWidget {
  @override
  _PinEntryScreenState createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final TextEditingController pinController = TextEditingController();
  final String correctPin = "4321";
  int attempts = 0;

  void checkPin() {
    if (pinController.text == correctPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ATMMenuScreen(balance: 10000.0, pin: correctPin)),
      );
    } else {
      setState(() {
        attempts++;
      });
      if (attempts >= 3) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Too Many Attempts"),
            content: Text("You have exceeded the maximum number of attempts."),
            actions: [
              TextButton(
                onPressed: () => exit(0),
                child: Text("Exit"),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Incorrect PIN. Attempts left: ${3 - attempts}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter PIN'),
      centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: pinController,
              decoration: InputDecoration(labelText: 'PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkPin,
              child: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}

class ATMMenuScreen extends StatefulWidget {
  double balance;
  String pin;
  ATMMenuScreen({required this.balance, required this.pin});

  @override
  _ATMMenuScreenState createState() => _ATMMenuScreenState();
}

class _ATMMenuScreenState extends State<ATMMenuScreen> {
  void updateBalance(double newBalance) {
    setState(() {
      widget.balance = newBalance;
    });
  }

  void updatePin(String newPin) {
    setState(() {
      widget.pin = newPin;
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      {'title': 'Balance Inquiry', 'action': () => showMessage('Current Balance: \$${widget.balance.toStringAsFixed(2)}')},
      {'title': 'Deposit Money', 'action': () => _showAmountDialog('Deposit', (amount) => updateBalance(widget.balance + amount))},
      {'title': 'Withdraw Cash', 'action': () => _showAmountDialog('Withdraw', (amount) => amount > widget.balance ? showMessage("Insufficient balance") : updateBalance(widget.balance - amount))},
      {'title': 'Transfer Money', 'action': () => _showAmountDialog('Transfer', (amount) => amount > widget.balance ? showMessage("Insufficient balance") : updateBalance(widget.balance - amount))},
      {'title': 'Change PIN', 'action': _changePinDialog},
      {'title': 'Pay Bills', 'action': () => _showAmountDialog('Pay Bills', (amount) => amount > widget.balance ? showMessage("Insufficient balance") : updateBalance(widget.balance - amount))},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('ATM Menu'),
        centerTitle: true,
        ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: options.map((option) {
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: InkWell(
                onTap: option['action'] as void Function(),
                child: Center(child: Text(option['title'] as String, textAlign: TextAlign.center)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAmountDialog(String title, Function(double) onConfirm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "Enter amount"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              double? amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                onConfirm(amount);
              } else {
                showMessage("Invalid amount.");
              }
            },
            child: Text("Confirm"),
          )
        ],
      ),
    );
  }

  void _changePinDialog() {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Change PIN"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPinController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Current PIN"),
            ),
            TextField(
              controller: newPinController,
              obscureText: true,
              decoration: InputDecoration(labelText: "New PIN (4 digits)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (oldPinController.text == widget.pin && newPinController.text.length == 4) {
                updatePin(newPinController.text);
                Navigator.pop(context);
                showMessage("PIN changed successfully.");
              } else {
                showMessage("Invalid input.");
              }
            },
            child: Text("Change"),
          )
        ],
      ),
    );
  }
}
