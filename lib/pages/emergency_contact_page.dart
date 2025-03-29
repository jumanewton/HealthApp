// screens/emergency_contact_page.dart
import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';
import '../services/emergency_contact_service.dart';
import '../widgets/add_contact_dialog.dart';
import '../widgets/contact_list_item.dart';

class EmergencyContactPage extends StatefulWidget {
  const EmergencyContactPage({super.key});

  @override
  State<EmergencyContactPage> createState() => _EmergencyContactPageState();
}

class _EmergencyContactPageState extends State<EmergencyContactPage> {
  final EmergencyContactService _contactService = EmergencyContactService();

  void _showAddContactDialog([EmergencyContact? contactToEdit]) {
    showDialog(
      context: context,
      builder: (context) => AddContactDialog(
        contactToEdit: contactToEdit,
        onAddContact: (contact) async {
          try {
            if (contact.id == null) {
              await _contactService.addContact(contact);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact added successfully')),
                );
              }
            } else {
              await _contactService.updateContact(contact);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact updated successfully')),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteContact(String contactId) async {
    try {
      await _contactService.deleteContact(contactId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting contact: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: StreamBuilder<List<EmergencyContact>>(
        stream: _contactService.getContactsStream(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          // No data or empty data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No emergency contacts added yet',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddContactDialog,
                    child: const Text('Add Emergency Contact'),
                  ),
                ],
              ),
            );
          }
          
          // Data available
          final contacts = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              
              return ContactListItem(
                contact: contact,
                onDelete: _deleteContact,
                onEdit: _showAddContactDialog,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}