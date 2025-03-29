// models/emergency_contact.dart
class EmergencyContact {
  final String? id;
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    this.id,
    required this.name,
    required this.phone,
    required this.relationship,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic> map, String docId) {
    return EmergencyContact(
      id: docId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      relationship: map['relationship'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }
}