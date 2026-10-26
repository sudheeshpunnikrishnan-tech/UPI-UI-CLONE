import 'package:flutter/material.dart';
import 'screens/payment_screen.dart';
import 'screens/pin_screen.dart';
import 'screens/success_screen.dart';
import 'screens/scan_qr_screen.dart';
import 'screens/contact_picker_screen.dart';

void main() {
  runApp(const UPICloneApp());
}

class UPICloneApp extends StatelessWidget {
  const UPICloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UPI Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
        useMaterial3: true,
      ),
      home: const UPIHomeScreen(),
    );
  }
}

class UPIHomeScreen extends StatefulWidget {
  const UPIHomeScreen({super.key});

  @override
  State<UPIHomeScreen> createState() => _UPIHomeScreenState();
}

class _UPIHomeScreenState extends State<UPIHomeScreen> {
  double accountBalance = 12500.00;

  final List<Map<String, dynamic>> recentTransactions = [
    {'name': 'Rahul K', 'amount': 350.0, 'date': 'Today, 11:20 AM', 'type': 'debit'},
    {'name': 'Ajay Kumar', 'amount': 1200.0, 'date': 'Yesterday', 'type': 'credit'},
    {'name': 'Grocery Store', 'amount': 450.0, 'date': '24 Oct', 'type': 'debit'},
  ];

  Future<void> _startPaymentFlow(String recipientName, String upiId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          recipientName: recipientName,
          upiId: upiId,
        ),
      ),
    );

    if (result != null && result is double) {
      final double amount = result;

      if (amount > accountBalance) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient balance!')),
        );
        return;
      }

      if (!mounted) return;
      final bool? pinSuccess = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PinScreen(
            recipientName: recipientName,
            amount: amount,
          ),
        ),
      );

      if (pinSuccess == true && mounted) {
        setState(() {
          accountBalance -= amount;
          recentTransactions.insert(0, {
            'name': recipientName,
            'amount': amount,
            'date': 'Just now',
            'type': 'debit',
          });
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              recipientName: recipientName,
              amount: amount,
            ),
          ),
        );
      }
    }
  }

  void _showPhoneNumberDialog() {
    final TextEditingController phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Mobile Number'),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: const InputDecoration(
            hintText: '10-digit number',
            prefixText: '+91 ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = phoneController.text.trim();
              if (text.length == 10) {
                Navigator.pop(context);
                _startPaymentFlow('User ($text)', '$text@upi');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid 10-digit number')),
                );
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI Pay', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.blue.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          '₹${accountBalance.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Icon(Icons.account_balance_wallet, color: Colors.white, size: 36),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Transfer Money', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.qr_code_scanner, 'Scan QR', () async {
                  final dynamic qrData = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanQrScreen()),
                  );
                  if (qrData != null && qrData is Map<String, dynamic>) {
                    _startPaymentFlow(qrData['name'].toString(), qrData['upiId'].toString());
                  }
                }),
                _buildActionButton(Icons.contacts, 'Contacts', () async {
                  final dynamic contactData = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ContactPickerScreen()),
                  );
                  if (contactData != null && contactData is Map<String, dynamic>) {
                    _startPaymentFlow(contactData['name'].toString(), contactData['upiId'].toString());
                  }
                }),
                _buildActionButton(Icons.phone_android, 'Phone No', _showPhoneNumberDialog),
                _buildActionButton(Icons.account_balance, 'To UPI ID', () {
                  _startPaymentFlow('Friend', 'user@bank');
                }),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentTransactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = recentTransactions[index];
                final isDebit = item['type'] == 'debit';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(
                      isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isDebit ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(item['date']),
                  trailing: Text(
                    '${isDebit ? '-' : '+'} ₹${item['amount']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDebit ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: Colors.blue.shade800, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
