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
  final String initialPin;

  PinEntryScreen({this.initialPin = "4321"}); // Default PIN is "4321"

  @override
  _PinEntryScreenState createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final TextEditingController pinController = TextEditingController();
  late String correctPin;
  int attempts = 0;

  @override
  void initState() {
    super.initState();
    correctPin = widget.initialPin; // Initialize with the passed PIN
  }

  void checkPin() {
    if (pinController.text == correctPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ATMMenuScreen(balance: 10000.0, pin: correctPin),
        ),
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
      appBar: AppBar(
        title: Text('Enter PIN'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.greenAccent, Colors.lightGreenAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Text('ATM Options', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: Icon(Icons.menu, color: Colors.greenAccent),
              title: Text('Menu', style: TextStyle(fontSize: 16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.redAccent),
              title: Text('Logout', style: TextStyle(fontSize: 16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PinEntryScreen(initialPin: correctPin), // Pass the updated PIN
                  ),
                  (route) => false, // Remove all previous routes
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.lightGreenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 36,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Welcome to ATM!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.greenAccent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: pinController,
                    decoration: InputDecoration(
                      labelText: 'Enter PIN',
                      labelStyle: TextStyle(color: Colors.greenAccent),
                      border: InputBorder.none, // Remove default border
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: checkPin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
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
      {'title': 'Balance Inquiry', 'action': () => showMessage('Current Balance: \$${widget.balance.toStringAsFixed(2)}'), 'icon': Icons.account_balance_wallet},
      {'title': 'Deposit Money', 'action': () => _showAmountDialog('Deposit', (amount) => updateBalance(widget.balance + amount)), 'icon': Icons.attach_money},
      {'title': 'Withdraw Cash', 'action': () => _showAmountDialog('Withdraw', (amount) => amount > widget.balance ? showMessage("Insufficient balance") : updateBalance(widget.balance - amount)), 'icon': Icons.money_off},
      {'title': 'Transfer Money', 'action': () => _showAmountDialog('Transfer', (amount) => amount > widget.balance ? showMessage("Insufficient balance") : updateBalance(widget.balance - amount)), 'icon': Icons.send},
      {'title': 'Change PIN', 'action': _changePinDialog, 'icon': Icons.lock},
      {'title': 'Pay Bills', 'action': () => _showAmountDialog('Pay Bills', (amount) => amount > widget.balance ? showMessage("Insufficient balance") : updateBalance(widget.balance - amount)), 'icon': Icons.receipt},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('ATM Menu'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.greenAccent, Colors.lightGreenAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Text('ATM Options', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            ...options.map((option) {
              return ListTile(
                leading: Icon(option['icon'] as IconData, color: Colors.greenAccent),
                title: Text(option['title'] as String, style: TextStyle(fontSize: 16)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  (option['action'] as void Function())(); // Execute the action
                },
              );
            }).toList(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.redAccent),
              title: Text('Logout', style: TextStyle(fontSize: 16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PinEntryScreen(initialPin: widget.pin), // Pass the updated PIN
                  ),
                  (route) => false, // Remove all previous routes
                );
              },
            ),
          ],
        ),
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
              elevation: 6,
              shadowColor: Colors.greenAccent.withOpacity(0.3),
              child: InkWell(
                onTap: option['action'] as void Function(),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(option['icon'] as IconData, size: 40, color: Colors.greenAccent),
                      SizedBox(height: 8),
                      Text(option['title'] as String, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
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
