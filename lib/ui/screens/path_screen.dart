import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../app/providers/database_provider.dart';
import '../../app/providers/profile_provider.dart';
import '../../app/providers/profile_view_provider.dart';
import '../../domain/engine/calling.dart';
import '../../domain/model/models.dart';
import '../theme/tokens.dart';
import '../widgets/chips.dart';
import '../widgets/sigil_widget.dart';

class PathScreen extends ConsumerStatefulWidget {
  const PathScreen({super.key});

  @override
  ConsumerState<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends ConsumerState<PathScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<CallingDomain, GlobalKey> _domainKeys = {
    for (final d in CallingDomain.values) d: GlobalKey(),
  };

  void _scrollToDomain(CallingDomain domain) {
    final key = _domainKeys[domain];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final profileAsync = ref.watch(profileStreamProvider);
    final profileViewAsync = ref.watch(profileViewStateProvider);
    final completionsDao = ref.watch(completionsDaoProvider);
    final ledgerDao = ref.watch(ledgerDaoProvider);

    final chosenDomain = profileAsync.value?.calling != null
        ? CallingDomain.values[profileAsync.value!.calling!]
        : CallingDomain.warrior;

    final currentLevel = profileViewAsync.value?.progression.level ?? 1;

    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: AppBar(
        backgroundColor: tokens.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'THE PATH',
          style: tokens.headline(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: tokens.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: LevelChip(level: currentLevel),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          completionsDao.getCompletionsInDateRange('2000-01-01', '2100-01-01'),
          ledgerDao.getAllXpEvents(),
          ref.read(questsDaoProvider).getActiveQuests(),
        ]),
        builder: (context, snapshot) {
          final completions = (snapshot.data?[0] as List<dynamic>?) ?? [];
          final xpEvents = (snapshot.data?[1] as List<dynamic>?) ?? [];
          final quests = (snapshot.data?[2] as List<dynamic>?) ?? [];

          // Compute per-domain stats
          final Map<CallingDomain, int> domainXp = {
            for (final d in CallingDomain.values) d: 0,
          };
          final Map<CallingDomain, int> domainCompletions = {
            for (final d in CallingDomain.values) d: 0,
          };

          final Map<String, CallingDomain> questDomainMap = {};
          for (final q in quests) {
            if (q.domain != null) {
              questDomainMap[q.id] = CallingDomain.values[q.domain!];
            }
          }

          for (final c in completions) {
            final dom = questDomainMap[c.questId];
            if (dom != null) {
              domainCompletions[dom] = (domainCompletions[dom] ?? 0) + (c.value as int);
            }
          }

          for (final e in xpEvents) {
            if (e.periodRef != null && e.periodRef!.contains('|')) {
              final qId = e.periodRef!.split('|').first;
              final dom = questDomainMap[qId];
              if (dom != null) {
                domainXp[dom] = (domainXp[dom] ?? 0) + (e.amount as int);
              }
            }
          }

          final List<DomainStats> allStats = CallingDomain.values.map((d) {
            return CallingEngine.calculateDomainStats(
              domain: d,
              domainXp: domainXp[d] ?? 0,
              completionsCount: domainCompletions[d] ?? 0,
            );
          }).toList();

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Radial Mini-Map (~260dp)
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    alignment: Alignment.center,
                    child: _RadialMap(
                      chosenDomain: chosenDomain,
                      stats: allStats,
                      onBranchTap: _scrollToDomain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Six Domain Progression Rows
                Text(
                  'CALLING BRANCHES',
                  style: tokens.monoText(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                for (final stats in allStats)
                  Padding(
                    key: _domainKeys[stats.domain],
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _DomainBranchCard(
                      stats: stats,
                      isChosen: stats.domain == chosenDomain,
                    ),
                  ),

                const SizedBox(height: 16),

                // Multiclass Teaser Row
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: tokens.tonal.withOpacity(0.5),
                    border: Border.all(
                      color: tokens.lineRule,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Symbols.lock,
                        size: 20,
                        color: tokens.textSecondary.withOpacity(0.4),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MULTICLASS · SECOND CALLING — L15',
                              style: tokens.monoText(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: tokens.textSecondary.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Unlock dual-domain affinities upon achieving Level 15 Veteran rank.',
                              style: tokens.body(
                                fontSize: 12,
                                color: tokens.textSecondary.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RadialMap extends StatelessWidget {
  final CallingDomain chosenDomain;
  final List<DomainStats> stats;
  final ValueChanged<CallingDomain> onBranchTap;

  const _RadialMap({
    required this.chosenDomain,
    required this.stats,
    required this.onBranchTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    const double size = 280;
    const double radius = 100;
    const center = Offset(size / 2, size / 2);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Radial Lines Painter
          CustomPaint(
            size: const Size(size, size),
            painter: _RadialLinesPainter(
              chosenDomain: chosenDomain,
              tokens: tokens,
              radius: radius,
            ),
          ),

          // Central Crest
          Positioned(
            left: center.dx - 24,
            top: center.dy - 24,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: tokens.tonal,
                border: Border.all(color: tokens.accent, width: 2),
              ),
              alignment: Alignment.center,
              child: SigilWidget(
                domain: chosenDomain,
                size: 26,
                color: tokens.accent,
              ),
            ),
          ),

          // 6 Outer Nodes
          ...List.generate(6, (i) {
            final domain = CallingDomain.values[i];
            final angle = (i * 60.0 - 90.0) * math.pi / 180.0;
            final nodeX = center.dx + radius * math.cos(angle) - 20;
            final nodeY = center.dy + radius * math.sin(angle) - 20;
            final isChosen = domain == chosenDomain;

            return Positioned(
              left: nodeX,
              top: nodeY,
              child: GestureDetector(
                onTap: () => onBranchTap(domain),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tokens.bg,
                    border: Border.all(
                      color: isChosen ? tokens.accent : tokens.lineRest,
                      width: isChosen ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: SigilWidget(
                    domain: domain,
                    size: 20,
                    color: isChosen ? tokens.accent : tokens.textSecondary,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RadialLinesPainter extends CustomPainter {
  final CallingDomain chosenDomain;
  final AppTokens tokens;
  final double radius;

  _RadialLinesPainter({
    required this.chosenDomain,
    required this.tokens,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 6; i++) {
      final domain = CallingDomain.values[i];
      final isChosen = domain == chosenDomain;
      final angle = (i * 60.0 - 90.0) * math.pi / 180.0;
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final paint = Paint()
        ..color = isChosen ? tokens.accent : tokens.lineRest
        ..strokeWidth = isChosen ? 2.0 : 1.0;

      canvas.drawLine(center, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadialLinesPainter oldDelegate) {
    return oldDelegate.chosenDomain != chosenDomain;
  }
}

class _DomainBranchCard extends StatelessWidget {
  final DomainStats stats;
  final bool isChosen;

  const _DomainBranchCard({
    required this.stats,
    required this.isChosen,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.tonal,
        border: Border.all(
          color: isChosen ? tokens.accent : tokens.lineRest,
          width: isChosen ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              SigilWidget(
                domain: stats.domain,
                size: 24,
                color: isChosen ? tokens.accent : tokens.textPrimary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.domain.name.toUpperCase(),
                      style: tokens.headline(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isChosen ? tokens.accent : tokens.textPrimary,
                      ),
                    ),
                    Text(
                      stats.info.tagline,
                      style: tokens.body(fontSize: 12, color: tokens.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${stats.totalXp} XP',
                    style: tokens.monoText(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: tokens.accent,
                    ),
                  ),
                  Text(
                    stats.tierTitle,
                    style: tokens.monoText(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Milestone Progression Track (250 / 1000 / 5000)
          Row(
            children: [
              _MilestoneNode(
                label: 'I (250)',
                isEarned: stats.tier >= 1,
                isNext: stats.tier == 0,
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: stats.tier >= 1 ? tokens.accent : tokens.lineRule,
                ),
              ),
              _MilestoneNode(
                label: 'II (1K)',
                isEarned: stats.tier >= 2,
                isNext: stats.tier == 1,
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: stats.tier >= 2 ? tokens.accent : tokens.lineRule,
                ),
              ),
              _MilestoneNode(
                label: 'III (5K)',
                isEarned: stats.tier >= 3,
                isNext: stats.tier == 2,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Trial Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: tokens.bg,
              border: Border.all(color: tokens.lineRule, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Symbols.verified,
                  size: 16,
                  color: stats.tier >= 1 ? tokens.accent : tokens.textSecondary.withOpacity(0.4),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${stats.info.trialName}: ${stats.info.trialDescription}',
                    style: tokens.body(
                      fontSize: 11,
                      color: tokens.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneNode extends StatelessWidget {
  final String label;
  final bool isEarned;
  final bool isNext;

  const _MilestoneNode({
    required this.label,
    required this.isEarned,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    Color nodeColor = Colors.transparent;
    Border nodeBorder = Border.all(color: tokens.lineRule, width: 1);

    if (isEarned) {
      nodeColor = tokens.accent;
      nodeBorder = Border.all(color: tokens.accent, width: 1);
    } else if (isNext) {
      nodeColor = tokens.tonal;
      nodeBorder = Border.all(color: tokens.accent, width: 1.5);
    }

    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: nodeColor,
            border: nodeBorder,
          ),
          alignment: Alignment.center,
          child: isEarned
              ? Icon(
                  Symbols.check,
                  size: 10,
                  color: tokens.onSolid,
                  weight: 800,
                )
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: tokens.monoText(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: isEarned || isNext ? tokens.textPrimary : tokens.textSecondary.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
