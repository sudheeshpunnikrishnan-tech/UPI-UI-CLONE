import 'package:flutter/material.dart';

class PinScreen extends StatefulWidget {
  final String recipientName;
  final double amount;

  const PinScreen({
    super.key,
    required this.recipientName,
    required this.amount,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String enteredPin = '';
  final int pinLength = 4;

  void _onKeyPress(String value) {
    if (enteredPin.length < pinLength) {
      setState(() {
        enteredPin += value;
      });

      // 4 അക്കങ്ങളും അടിച്ചുകഴിഞ്ഞാൽ അടുത്ത സ്ക്രീനിലേക്ക് കടക്കാം
      if (enteredPin.length == pinLength) {
        _submitPin();
      }
    }
  }

  void _onBackspace() {
    if (enteredPin.isNotEmpty) {
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      });
    }
  }

  void _submitPin() {
    // സിമുലേഷൻ ലോജിക്: ശരിയായ പിൻ അടിക്കുമ്പോൾ സക്സസ് ആകുന്നു
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ENTER UPI PIN', style: TextStyle(fontSize: 14, letterSpacing: 1.2)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // ഇടപാട് വിവരങ്ങൾ
          Text(
            widget.recipientName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '₹${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 36),

          // PIN Indicators (Dots)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pinLength, (index) {
              final isFilled = index < enteredPin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? Colors.blue.shade900 : Colors.transparent,
                  border: Border.all(color: Colors.blue.shade900, width: 2),
                ),
              );
            }),
          ),

          const Spacer(),

          // സുരക്ഷാ നിർദ്ദേശം
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 6),
              Text(
                'UPI PIN will keep your account secure',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // കസ്റ്റം ന്യൂമെറിക് കീപാഡ്
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                _buildKeyboardRow(['1', '2', '3']),
                _buildKeyboardRow(['4', '5', '6']),
                _buildKeyboardRow(['7', '8', '9']),
                _buildKeyboardBottomRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((key) => _buildKey(key)).toList(),
      ),
    );
  }

  Widget _buildKeyboardBottomRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(width: 64, height: 48), // Empty placeholder
          _buildKey('0'),
          InkWell(
            onTap: _onBackspace,
            borderRadius: BorderRadius.circular(24),
            child: const SizedBox(
              width: 64,
              height: 48,
              child: Center(child: Icon(Icons.backspace_outlined, size: 24)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String value) {
    return InkWell(
      onTap: () => _onKeyPress(value),
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 64,
        height: 48,
        child: Center(
          child: Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
