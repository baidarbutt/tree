class FamilyMember {
  final String id;
  final String userId;
  final String fullName;
  final String relation;
  final int generation;
  final String? gender;
  final DateTime? birthDate;
  final DateTime? deathDate;
  final String? notes;
  final String? photoUrl;

  FamilyMember({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.relation,
    required this.generation,
    this.gender,
    this.birthDate,
    this.deathDate,
    this.notes,
    this.photoUrl,
  });

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      fullName: map['full_name'] as String,
      relation: map['relation'] as String,
      generation: map['generation'] as int,
      gender: map['gender'] as String?,
      birthDate: map['birth_date'] != null
          ? DateTime.parse(map['birth_date'] as String)
          : null,
      deathDate: map['death_date'] != null
          ? DateTime.parse(map['death_date'] as String)
          : null,
      notes: map['notes'] as String?,
      photoUrl: map['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap(String userId) {
    return {
      'user_id': userId,
      'full_name': fullName,
      'relation': relation,
      'generation': generation,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String().split('T').first,
      'death_date': deathDate?.toIso8601String().split('T').first,
      'notes': notes,
      'photo_url': photoUrl,
    };
  }
}

/// Maps a chosen relation label to a generation level relative to the user
/// (0 = the user's own generation).
const Map<String, int> relationToGeneration = {
  'Self': 0,
  'Spouse': 0,
  'Sibling': 0,
  'Cousin': 0,
  'Father': -1,
  'Mother': -1,
  'Uncle': -1,
  'Aunt': -1,
  'Grandfather (Paternal)': -2,
  'Grandmother (Paternal)': -2,
  'Grandfather (Maternal)': -2,
  'Grandmother (Maternal)': -2,
  'Child': 1,
  'Nephew/Niece': 1,
  'Grandchild': 2,
  'Other': 0,
};

const List<String> relationOptions = [
  'Self',
  'Spouse',
  'Father',
  'Mother',
  'Grandfather (Paternal)',
  'Grandmother (Paternal)',
  'Grandfather (Maternal)',
  'Grandmother (Maternal)',
  'Sibling',
  'Child',
  'Grandchild',
  'Uncle',
  'Aunt',
  'Cousin',
  'Nephew/Niece',
  'Other',
];

String generationLabel(int gen) {
  switch (gen) {
    case -2:
      return 'Grandparents';
    case -1:
      return 'Parents';
    case 0:
      return 'My Generation';
    case 1:
      return 'Children';
    case 2:
      return 'Grandchildren';
    default:
      return 'Other';
  }
}
