import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactPickerScreen extends StatefulWidget {
  const ContactPickerScreen({super.key});

  @override
  State<ContactPickerScreen> createState() => _ContactPickerScreenState();
}

class _ContactPickerScreenState extends State<ContactPickerScreen> {
  List<Contact> _contacts = [];
  bool _isLoading = true;
  String _permissionStatus = '';

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } else {
      setState(() {
        _permissionStatus = 'Contacts permission denied';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact to Pay'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _permissionStatus.isNotEmpty
              ? Center(child: Text(_permissionStatus))
              : _contacts.isEmpty
                  ? const Center(child: Text('No contacts found'))
                  : ListView.separated(
                      itemCount: _contacts.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        final phone = contact.phones.isNotEmpty ? contact.phones.first.number : 'No number';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              contact.displayName.isNotEmpty ? contact.displayName[0].toUpperCase() : '?',
                              style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(contact.displayName),
                          subtitle: Text(phone),
                          onTap: () {
                            final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
                            Navigator.of(context).pop({
                              'name': contact.displayName,
                              'upiId': '$cleanPhone@upi',
                            });
                          },
                        );
                      },
                    ),
    );
  }
}
