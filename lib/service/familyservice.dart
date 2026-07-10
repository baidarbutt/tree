import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tree/model/familymodel.dart';

class FamilyService {
  SupabaseClient get _client => Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  /// Fetch all family members belonging to the current user,
  /// ordered by generation then name.
  Future<List<FamilyMember>> fetchFamilyMembers() async {
    final data = await _client
        .from('family_members')
        .select()
        .eq('user_id', _userId)
        .order('generation', ascending: true)
        .order('full_name', ascending: true);

    return (data as List)
        .map((row) => FamilyMember.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFamilyMember(FamilyMember member) async {
    await _client.from('family_members').insert(member.toInsertMap(_userId));
  }

  Future<void> deleteFamilyMember(String id) async {
    await _client.from('family_members').delete().eq('id', id);
  }

  Future<void> updateFamilyMember(String id, FamilyMember member) async {
    await _client
        .from('family_members')
        .update(member.toInsertMap(_userId))
        .eq('id', id);
  }
}
