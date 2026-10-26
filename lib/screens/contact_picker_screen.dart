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
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      try {
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );
        setState(() {
          _contacts = contacts.where((c) => c.phones.isNotEmpty).toList();
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to load contacts';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Permission denied to read contacts';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _contacts.isEmpty
                  ? const Center(child: Text('No contacts with phone numbers found'))
                  : ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        final phone = contact.phones.first.number;
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              contact.displayName.isNotEmpty
                                  ? contact.displayName[0].toUpperCase()
                                  : '?',
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
