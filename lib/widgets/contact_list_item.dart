// widgets/contact_list_item.dart
import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';
import '../services/phone_service.dart';

class ContactListItem extends StatelessWidget {
  final EmergencyContact contact;
  final Function(String) onDelete;
  final Function(EmergencyContact) onEdit;

  const ContactListItem({
    super.key,
    required this.contact,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(contact.id ?? ''),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        if (contact.id != null) {
          onDelete(contact.id!);
        }
      },
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text('Are you sure you want to delete ${contact.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: InkWell(
          onTap: () => onEdit(contact),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(contact.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.relationship),
                Text(contact.phone),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: () async {
                    final success = await PhoneService.makePhoneCall(contact.phone);
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not launch phone call')),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.message, color: Colors.blue),
                  onPressed: () async {
                    final success = await PhoneService.sendSms(contact.phone);
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not launch SMS')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}