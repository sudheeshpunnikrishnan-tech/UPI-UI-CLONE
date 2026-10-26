import 'dart:math';
import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final String recipientName;
  final double amount;

  const SuccessScreen({
    super.key,
    required this.recipientName,
    required this.amount,
  });

  // റിയലിസ്റ്റിക് ആയി തോന്നാൻ ഒരു ഡമ്മി UTR നമ്പർ ഉണ്ടാക്കുന്നു
  String _generateUtr() {
    final random = Random();
    return List.generate(12, (_) => random.nextInt(10)).join();
  }

  @override
  Widget build(BuildContext context) {
    final utrNumber = _generateUtr();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green.shade600,
                  size: 70,
                ),
              ),
              const SizedBox(height: 24),

              // Success Text & Amount
              const Text(
                'Paid Successfully',
                style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'to $recipientName',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),

              // Receipt Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('UPI Transaction ID', 'UPI/$utrNumber'),
                    const Divider(height: 20),
                    _buildReceiptRow('To', recipientName),
                    const Divider(height: 20),
                    _buildReceiptRow('Status', 'Completed'),
                  ],
                ),
              ),

              const Spacer(),

              // Done Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // തിരിച്ച് ഹോം സ്‌ക്രീനിലേക്ക് പോകാൻ
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}
