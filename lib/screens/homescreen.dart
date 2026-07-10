import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tree/model/familymodel.dart';
import 'package:tree/screens/addmemberscreen.dart';
import 'package:tree/service/familyservice.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _familyService = FamilyService();
  late Future<List<FamilyMember>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  void _loadMembers() {
    setState(() {
      _membersFuture = _familyService.fetchFamilyMembers();
    });
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    // AuthGate in main.dart automatically returns to LoginScreen.
  }

  Future<void> _openAddMember() async {
    final added = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddMemberScreen()));
    if (added == true) _loadMembers();
  }

  Future<void> _deleteMember(FamilyMember member) async {
    await _familyService.deleteFamilyMember(member.id);
    _loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Center(
          child: const Text(
            'My Family Tree',
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadMembers(),
        child: FutureBuilder<List<FamilyMember>>(
          future: _membersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text('Error loading data: ${snapshot.error}')),
                ],
              );
            }

            final members = snapshot.data ?? [];
            if (members.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.family_restroom, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Center(
                    child: Text(
                      'No family members yet.\nTap + to add your first one.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }

            // Group members by generation, oldest generation first.
            final Map<int, List<FamilyMember>> grouped = {};
            for (final m in members) {
              grouped.putIfAbsent(m.generation, () => []).add(m);
            }
            final sortedGenerations = grouped.keys.toList()..sort();

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: sortedGenerations.length,
              itemBuilder: (context, index) {
                final gen = sortedGenerations[index];
                final membersInGen = grouped[gen]!;
                return _GenerationSection(
                  title: generationLabel(gen),
                  members: membersInGen,
                  onDelete: _deleteMember,
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddMember,
        icon: const Icon(Icons.add),
        label: const Text('Add Member'),
      ),
    );
  }
}

class _GenerationSection extends StatelessWidget {
  final String title;
  final List<FamilyMember> members;
  final void Function(FamilyMember) onDelete;

  const _GenerationSection({
    required this.title,
    required this.members,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
        ...members.map(
          (member) => _MemberCard(member: member, onDelete: onDelete),
        ),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  final FamilyMember member;
  final void Function(FamilyMember) onDelete;

  const _MemberCard({required this.member, required this.onDelete});

  String get _subtitle {
    final parts = <String>[member.relation];
    if (member.birthDate != null) {
      parts.add('b. ${member.birthDate!.year}');
    }
    if (member.deathDate != null) {
      parts.add('d. ${member.deathDate!.year}');
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          backgroundImage: member.photoUrl != null
              ? NetworkImage(member.photoUrl!)
              : null,
          child: member.photoUrl == null
              ? Text(
                  member.fullName.isNotEmpty
                      ? member.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(member.fullName),
        subtitle: Text(_subtitle),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.grey),
          onPressed: () => _confirmDelete(context),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove family member?'),
        content: Text('This will remove ${member.fullName} from your tree.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete(member);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
