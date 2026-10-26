import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

enum PaymentStatus { loading, success, failed, processing }

class TransactionStatusScreen extends StatefulWidget {
  final String recipientName;
  final double amount;

  const TransactionStatusScreen({
    super.key,
    required this.recipientName,
    required this.amount,
  });

  @override
  State<TransactionStatusScreen> createState() => _TransactionStatusScreenState();
}

class _TransactionStatusScreenState extends State<TransactionStatusScreen> {
  PaymentStatus _currentStatus = PaymentStatus.loading;
  String _utrNumber = '';

  @override
  void initState() {
    super.initState();
    _startSimulatedPayment();
  }

  void _startSimulatedPayment() {
    final random = Random();
    _utrNumber = List.generate(12, (_) => random.nextInt(10)).join();

    // 2.5 സെക്കൻഡ് ലോഡിംഗ് കാണിച്ച ശേഷം ഫലം തീരുമാനിക്കുന്നു
    Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;

      // 70% Success, 15% Failed, 15% Processing
      final outcome = random.nextInt(100);
      setState(() {
        if (outcome < 70) {
          _currentStatus = PaymentStatus.success;
        } else if (outcome < 85) {
          _currentStatus = PaymentStatus.failed;
        } else {
          _currentStatus = PaymentStatus.processing;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _currentStatus != PaymentStatus.loading,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                _buildStatusContent(),
                const Spacer(),
                if (_currentStatus != PaymentStatus.loading)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // വിജയിച്ചാൽ മാത്രമേ തുക കുറയ്ക്കാൻ റിസൾട്ട് നൽകാവൂ
                        Navigator.of(context).pop(_currentStatus == PaymentStatus.success);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getThemeColor(),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: Text(
                        _currentStatus == PaymentStatus.failed ? 'Retry / Done' : 'Done',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusContent() {
    switch (_currentStatus) {
      case PaymentStatus.loading:
        return Column(
          children: [
            const SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(strokeWidth: 4),
            ),
            const SizedBox(height: 32),
            const Text(
              'Processing Payment...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Paying ₹${widget.amount.toStringAsFixed(2)} to ${widget.recipientName}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Text(
              'Please do not press back or close the app',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        );

      case PaymentStatus.success:
        return _buildResultCard(
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green,
          title: 'Paid Successfully',
          subtitle: 'Money sent to ${widget.recipientName}',
          statusLabel: 'Completed',
        );

      case PaymentStatus.failed:
        return _buildResultCard(
          icon: Icons.cancel_rounded,
          iconColor: Colors.red,
          title: 'Payment Failed',
          subtitle: 'Bank server unreachable. Money not deducted.',
          statusLabel: 'Failed',
        );

      case PaymentStatus.processing:
        return _buildResultCard(
          icon: Icons.access_time_filled_rounded,
          iconColor: Colors.orange,
          title: 'Payment Processing',
          subtitle: 'Bank is confirming your transaction.',
          statusLabel: 'Pending',
        );
    }
  }

  Widget _buildResultCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String statusLabel,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 84),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: iconColor),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          '₹${widget.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildRow('UPI Ref No (UTR)', _utrNumber),
              const Divider(height: 18),
              _buildRow('To', widget.recipientName),
              const Divider(height: 18),
              _buildRow('Payment Status', statusLabel),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Color _getThemeColor() {
    switch (_currentStatus) {
      case PaymentStatus.success:
        return const Color(0xFF1A73E8);
      case PaymentStatus.failed:
        return Colors.red.shade700;
      case PaymentStatus.processing:
        return Colors.orange.shade800;
      default:
        return const Color(0xFF1A73E8);
    }
  }
}
