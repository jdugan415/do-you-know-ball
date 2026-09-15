import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../quiz/daily_challenge_card.dart';
import '../quiz/daily_gift_banner.dart';
import '../roster/roster_repository.dart';
import 'team.dart';
import 'team_detail_screen.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key, required this.repository});
  final RosterRepository repository;
  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  late Future<List<NflTeam>> _teams;
  final _search = TextEditingController();
  String _conference = 'All';
  @override
  void initState() {
    super.initState();
    _teams = widget.repository.loadTeams();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: ink,
            hoverColor: const Color(0xFFFFDF85),
            highlightColor: const Color(0xFFFFB61D),
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.all(12),
            side: const BorderSide(color: Color(0xFFFFE6A1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          tooltip: 'Daily challenge',
          icon: const Icon(Icons.today),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  DailyChallengeScreen(repository: widget.repository),
            ),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.only(right: 12),
      title: const Text(
        'DYKB / FOOTBALL',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DailyGiftBanner(repository: widget.repository),
                      const SizedBox(height: 24),
                      const Text(
                        'Do you know ball?',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '32 teams. Ten players. Choose your challenge.',
                        style: TextStyle(color: Color(0xFFB8BEBD)),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Search teams',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _search.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => setState(_search.clear),
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final label in ['All', 'AFC', 'NFC'])
                            ChoiceChip(
                              label: Text(label),
                              selected: _conference == label,
                              onSelected: (_) =>
                                  setState(() => _conference = label),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FutureBuilder<List<NflTeam>>(
                  future: _teams,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: TextButton(
                          onPressed: () => setState(() {
                            _teams = widget.repository.loadTeams();
                          }),
                          child: const Text('Could not load teams. Try again'),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final query = _search.text.trim().toLowerCase();
                    final teams = snapshot.data!
                        .where(
                          (t) =>
                              (_conference == 'All' ||
                                  t.conference == _conference) &&
                              ('${t.name} ${t.id} ${t.conference} ${t.division}'
                                  .toLowerCase()
                                  .contains(query)),
                        )
                        .toList();
                    if (teams.isEmpty) {
                      return const Center(
                        child: Text('No teams found. Try another search.'),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      itemCount: teams.length + 1,
                      itemBuilder: (context, i) {
                        if (i == teams.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Independent fan project. Not affiliated with the NFL or its teams.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB8BEBD),
                              ),
                            ),
                          );
                        }
                        final team = teams[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            key: ValueKey('team-${team.id}'),
                            contentPadding: const EdgeInsets.all(14),
                            leading: CircleAvatar(
                              backgroundColor: Color(team.color),
                              child: Text(
                                team.id,
                                style: const TextStyle(
                                  color: ink,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            title: Text(
                              team.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${team.conference} ${team.division}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => TeamDetailScreen(
                                  team: team,
                                  repository: widget.repository,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
