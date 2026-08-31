import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../domain/model/models.dart';
import '../../domain/templates.dart';
import '../theme/tokens.dart';
import '../widgets/chips.dart';
import '../widgets/sigil_widget.dart';

class TemplatePickerSheet extends StatefulWidget {
  const TemplatePickerSheet({super.key});

  static Future<QuestTemplate?> show(BuildContext context) {
    return showModalBottomSheet<QuestTemplate>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const TemplatePickerSheet(),
    );
  }

  @override
  State<TemplatePickerSheet> createState() => _TemplatePickerSheetState();
}

class _TemplatePickerSheetState extends State<TemplatePickerSheet> {
  String _selectedCategory = 'ALL';

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    final filteredTemplates = _selectedCategory == 'ALL'
        ? StarterTemplates.templates
        : StarterTemplates.templates
            .where((t) => t.category == _selectedCategory)
            .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: tokens.bg,
        border: Border(
          top: BorderSide(color: tokens.accent, width: 2),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'QUEST TEMPLATES',
                  style: tokens.headline(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Symbols.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Categories Filter
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: StarterTemplates.categories.length,
              itemBuilder: (context, index) {
                final cat = StarterTemplates.categories[index];
                final isSelected = cat == _selectedCategory;

                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? tokens.accent : tokens.tonal,
                      border: Border.all(
                        color: isSelected ? tokens.accent : tokens.lineRule,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: tokens.monoText(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? tokens.onSolid : tokens.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Template List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: filteredTemplates.length,
              itemBuilder: (context, index) {
                final t = filteredTemplates[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(t),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: tokens.tonal,
                        border: Border.all(color: tokens.lineRule, width: 1),
                      ),
                      child: Row(
                        children: [
                          SigilWidget(domain: t.domain, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        t.title,
                                        style: tokens.title(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: tokens.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (t.essential)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 6),
                                        child: EssentialStar(isEssential: true),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '${t.category} · ${t.rule.cadence.name.toUpperCase()} · ${t.difficulty.name.toUpperCase()}',
                                      style: tokens.monoText(
                                        fontSize: 11,
                                        color: tokens.textSecondary,
                                      ),
                                    ),
                                    if (t.targetType == TargetType.counter) ...[
                                      Text(
                                        ' (${t.targetValue} ${t.unit ?? ''})',
                                        style: tokens.monoText(
                                          fontSize: 11,
                                          color: tokens.accent,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(Symbols.arrow_forward, size: 16, color: tokens.textSecondary),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
