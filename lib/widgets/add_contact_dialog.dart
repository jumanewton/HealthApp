// widgets/add_contact_dialog.dart
import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';

class AddContactDialog extends StatefulWidget {
  final Function(EmergencyContact) onAddContact;
  final EmergencyContact? contactToEdit;

  const AddContactDialog({
    super.key,
    required this.onAddContact,
    this.contactToEdit,
  });

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _relationshipController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.contactToEdit != null;
    _nameController = TextEditingController(
      text: _isEditing ? widget.contactToEdit!.name : '',
    );
    _phoneController = TextEditingController(
      text: _isEditing ? widget.contactToEdit!.phone : '',
    );
    _relationshipController = TextEditingController(
      text: _isEditing ? widget.contactToEdit!.relationship : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    return _nameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _relationshipController.text.isNotEmpty;
  }

  void _submitForm() {
    if (!_validateInputs()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final contact = EmergencyContact(
      id: _isEditing ? widget.contactToEdit!.id : null,
      name: _nameController.text,
      phone: _phoneController.text,
      relationship: _relationshipController.text,
    );

    widget.onAddContact(contact);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Emergency Contact' : 'Add Emergency Contact'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _relationshipController,
              decoration: const InputDecoration(labelText: 'Relationship'),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submitForm,
          child: Text(_isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}