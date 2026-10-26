import 'package:flutter/material.dart';
import 'screens/payment_screen.dart';
import 'screens/pin_screen.dart';
import 'screens/success_screen.dart';

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

  // പേയ്‌മെന്റ് ഫ്ലോ ട്രിഗർ ചെയ്യുന്ന ഫംഗ്ഷൻ
  Future<void> _startPaymentFlow(String recipientName, String upiId) async {
    // 1. Payment Screen തുറക്കുന്നു
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          recipientName: recipientName,
          upiId: upiId,
        ),
      ),
    );

    // തുക നൽകി പ്രൊസീഡ് ചെയ്താൽ
    if (result != null && result is double) {
      final double amount = result;

      if (amount > accountBalance) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient balance!')),
        );
        return;
      }

      // 2. PIN Screen തുറക്കുന്നു
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

      // 3. പിൻ ശരിയാണെങ്കിൽ ബാലൻസ് കുറച്ച് Success Screen കാണിക്കുന്നു
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI Pay', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bank Balance Card
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

            // Quick Actions Header
            const Text('Transfer Money', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.qr_code_scanner, 'Scan QR', () {
                  _startPaymentFlow('Store Merchant', 'merchant@okaxis');
                }),
                _buildActionButton(Icons.contacts, 'Pay Contact', () {
                  _startPaymentFlow('Rahul K', 'rahul@okhdfcbank');
                }),
                _buildActionButton(Icons.phone_android, 'Phone No', () {
                  _startPaymentFlow('Friend', '9876543210@upi');
                }),
                _buildActionButton(Icons.account_balance, 'Bank Transfer', () {
                  _startPaymentFlow('Self Account', 'transfer@sbi');
                }),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Transactions Section
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
