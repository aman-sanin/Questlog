import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/db/database.dart';
import '../keeper/tunables.dart';
import '../model/models.dart';
import 'freezes.dart';

enum BadgeCategory {
  journey,
  streaks,
  perfection,
  goals,
  economy,
  rarities,
  calling,
  keeper,
  sealed,
}

enum ProgressKind {
  cumulative,
  peak,
  event,
}

class BadgeDefinition {
  final String key;
  final String title;
  final BadgeCategory category;
  final IconData icon;
  final String flavor;
  final String requirement;
  final ProgressKind progressKind;
  final int targetValue;
  final bool sealed;
  final CallingDomain? domain;

  const BadgeDefinition({
    required this.key,
    required this.title,
    required this.category,
    required this.icon,
    required this.flavor,
    required this.requirement,
    required this.progressKind,
    this.targetValue = 1,
    this.sealed = false,
    this.domain,
  });
}

class BadgeStatus {
  final BadgeDefinition definition;
  final bool isEarned;
  final int currentValue;
  final String? earnedDate;
  final bool isEligible;

  const BadgeStatus({
    required this.definition,
    required this.isEarned,
    this.currentValue = 0,
    this.earnedDate,
    this.isEligible = true,
  });

  double get progressRatio {
    if (definition.targetValue <= 0) return isEarned ? 1.0 : 0.0;
    return (currentValue / definition.targetValue).clamp(0.0, 1.0);
  }
}

class BadgeEngine {
  static const List<BadgeDefinition> catalog = [
    // ── 1. JOURNEY (11) ───────────────────────────────────────────────────────
    BadgeDefinition(
      key: 'first_step',
      title: 'First Step',
      category: BadgeCategory.journey,
      icon: Symbols.directions_walk,
      flavor: 'The log begins.',
      requirement: 'Complete your first quest.',
      progressKind: ProgressKind.cumulative,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'tenfold',
      title: 'Tenfold',
      category: BadgeCategory.journey,
      icon: Symbols.filter_9_plus,
      flavor: 'Ten entries in the book.',
      requirement: 'Complete 10 total quests.',
      progressKind: ProgressKind.cumulative,
      targetValue: 10,
    ),
    BadgeDefinition(
      key: 'half_century',
      title: 'Half-Century',
      category: BadgeCategory.journey,
      icon: Symbols.timeline,
      flavor: 'Fifty acts, recorded.',
      requirement: 'Complete 50 total quests.',
      progressKind: ProgressKind.cumulative,
      targetValue: 50,
    ),
    BadgeDefinition(
      key: 'century',
      title: 'Century',
      category: BadgeCategory.journey,
      icon: Symbols.workspace_premium,
      flavor: 'A hundred proofs of showing up.',
      requirement: 'Complete 100 total quests.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'millennial',
      title: 'Millennial',
      category: BadgeCategory.journey,
      icon: Symbols.emoji_events,
      flavor: 'The log outgrew its shelf.',
      requirement: 'Complete 1,000 total quests.',
      progressKind: ProgressKind.cumulative,
      targetValue: 1000,
    ),
    BadgeDefinition(
      key: 'long_log',
      title: 'The Long Log',
      category: BadgeCategory.journey,
      icon: Symbols.history_edu,
      flavor: 'A life, kept in entries.',
      requirement: 'Complete 5,000 total quests.',
      progressKind: ProgressKind.cumulative,
      targetValue: 5000,
    ),
    BadgeDefinition(
      key: 'twenty_five',
      title: 'Twenty-Five',
      category: BadgeCategory.journey,
      icon: Symbols.tag,
      flavor: 'A quarter of a hundred.',
      requirement: 'Complete 25 total quests.',
      progressKind: ProgressKind.cumulative,
      targetValue: 25,
    ),
    BadgeDefinition(
      key: 'quarter_thousand',
      title: 'Quarter Thousand',
      category: BadgeCategory.journey,
      icon: Symbols.layers,
      flavor: 'Two hundred fifty, kept.',
      requirement: 'Complete 250 total quests.',
      progressKind: ProgressKind.cumulative,
      targetValue: 250,
    ),
    BadgeDefinition(
      key: 'half_thousand',
      title: 'Half Thousand',
      category: BadgeCategory.journey,
      icon: Symbols.library_books,
      flavor: 'A small library of days.',
      requirement: 'Complete 500 total quests.',
      progressKind: ProgressKind.cumulative,
      targetValue: 500,
    ),
    BadgeDefinition(
      key: 'two_thousand',
      title: 'Two Thousand',
      category: BadgeCategory.journey,
      icon: Symbols.menu_book,
      flavor: 'Volumes, plural.',
      requirement: 'Complete 2,000 total quests.',
      progressKind: ProgressKind.cumulative,
      targetValue: 2000,
    ),
    BadgeDefinition(
      key: 'ten_thousand',
      title: 'Ten Thousand',
      category: BadgeCategory.journey,
      icon: Symbols.castle,
      flavor: 'A fortress of entries.',
      requirement: 'Complete 10,000 total quests.',
      progressKind: ProgressKind.cumulative,
      targetValue: 10000,
    ),

    // ── 2. STREAKS (12) ───────────────────────────────────────────────────────
    BadgeDefinition(
      key: 'weeks_worth',
      title: "A Week's Worth",
      category: BadgeCategory.streaks,
      icon: Symbols.local_fire_department,
      flavor: 'Seven in a row.',
      requirement: 'Reach a streak of 7 periods on any quest.',
      progressKind: ProgressKind.peak,
      targetValue: 7,
    ),
    BadgeDefinition(
      key: 'month_iron',
      title: 'Month of Iron',
      category: BadgeCategory.streaks,
      icon: Symbols.fort,
      flavor: 'Thirty periods, unbroken.',
      requirement: 'Reach a streak of 30 periods on any quest.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'streak_centurion',
      title: 'Centurion',
      category: BadgeCategory.streaks,
      icon: Symbols.military_tech,
      flavor: 'One hundred periods deep.',
      requirement: 'Reach a streak of 100 periods on any quest.',
      progressKind: ProgressKind.peak,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'long_year',
      title: 'The Long Year',
      category: BadgeCategory.streaks,
      icon: Symbols.event_available,
      flavor: 'A year without a miss.',
      requirement: 'Reach a streak of 365 periods on any quest.',
      progressKind: ProgressKind.peak,
      targetValue: 365,
    ),
    BadgeDefinition(
      key: 'thirty_weeks',
      title: 'Thirty Weeks',
      category: BadgeCategory.streaks,
      icon: Symbols.date_range,
      flavor: 'Thirty faithful weeks.',
      requirement: 'Reach a 30-week streak on any weekly quest.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'dozen_moons',
      title: 'A Dozen Moons',
      category: BadgeCategory.streaks,
      icon: Symbols.dark_mode,
      flavor: 'Twelve moons honored.',
      requirement: 'Reach a 12-month streak on any monthly quest.',
      progressKind: ProgressKind.peak,
      targetValue: 12,
    ),
    BadgeDefinition(
      key: 'three_ages',
      title: 'Three Ages',
      category: BadgeCategory.streaks,
      icon: Symbols.hourglass_top,
      flavor: 'Three annual returns.',
      requirement: 'Reach a 3-year streak on any yearly quest.',
      progressKind: ProgressKind.peak,
      targetValue: 3,
    ),
    BadgeDefinition(
      key: 'fortnight_fire',
      title: 'Fortnight Fire',
      category: BadgeCategory.streaks,
      icon: Symbols.bolt,
      flavor: 'Fourteen, burning.',
      requirement: 'Reach a streak of 14 periods on any quest.',
      progressKind: ProgressKind.peak,
      targetValue: 14,
    ),
    BadgeDefinition(
      key: 'fifty_stack',
      title: 'Fifty Stack',
      category: BadgeCategory.streaks,
      icon: Symbols.inventory,
      flavor: 'Fifty high.',
      requirement: 'Reach a streak of 50 periods on any quest.',
      progressKind: ProgressKind.peak,
      targetValue: 50,
    ),
    BadgeDefinition(
      key: 'double_century',
      title: 'Double Century',
      category: BadgeCategory.streaks,
      icon: Symbols.shield,
      flavor: 'Two hundred deep.',
      requirement: 'Reach a streak of 200 periods on any quest.',
      progressKind: ProgressKind.peak,
      targetValue: 200,
    ),
    BadgeDefinition(
      key: 'twelve_weeks',
      title: 'Twelve Weeks',
      category: BadgeCategory.streaks,
      icon: Symbols.calendar_view_week,
      flavor: 'A quarter of weeks.',
      requirement: 'Reach a 12-week streak on any weekly quest.',
      progressKind: ProgressKind.peak,
      targetValue: 12,
    ),
    BadgeDefinition(
      key: 'half_year_moons',
      title: 'Half-Year Moons',
      category: BadgeCategory.streaks,
      icon: Symbols.nightlight,
      flavor: 'Six moons honored.',
      requirement: 'Reach a 6-month streak on any monthly quest.',
      progressKind: ProgressKind.peak,
      targetValue: 6,
    ),

    // ── 3. PERFECTION (11) ────────────────────────────────────────────────────
    BadgeDefinition(
      key: 'perfect_ten',
      title: 'Perfect Ten',
      category: BadgeCategory.perfection,
      icon: Symbols.auto_awesome,
      flavor: 'Ten days without a miss.',
      requirement: 'Achieve 10 Perfect Days.',
      progressKind: ProgressKind.cumulative,
      targetValue: 10,
    ),
    BadgeDefinition(
      key: 'fifty_flawless',
      title: 'Fifty Flawless',
      category: BadgeCategory.perfection,
      icon: Symbols.verified,
      flavor: 'Fifty clean pages.',
      requirement: 'Achieve 50 Perfect Days.',
      progressKind: ProgressKind.cumulative,
      targetValue: 50,
    ),
    BadgeDefinition(
      key: 'perfect_hundred',
      title: 'Perfect Hundred',
      category: BadgeCategory.perfection,
      icon: Symbols.diamond,
      flavor: 'A hundred flawless entries.',
      requirement: 'Achieve 100 Perfect Days.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'first_perfect_week',
      title: 'First Perfect Week',
      category: BadgeCategory.perfection,
      icon: Symbols.check_circle,
      flavor: 'One whole week, kept.',
      requirement: 'Achieve 1 Perfect Week.',
      progressKind: ProgressKind.cumulative,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'flawless_fortnight',
      title: 'Flawless Fortnight',
      category: BadgeCategory.perfection,
      icon: Symbols.done_all,
      flavor: 'Fourteen days, no asterisks.',
      requirement: 'Achieve 14 consecutive Perfect Days.',
      progressKind: ProgressKind.peak,
      targetValue: 14,
    ),
    BadgeDefinition(
      key: 'perfect_month',
      title: 'The Perfect Month',
      category: BadgeCategory.perfection,
      icon: Symbols.calendar_view_month,
      flavor: 'A month without a blemish.',
      requirement: 'Every eligible day of a calendar month perfect (≥20 eligible days).',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'perfect_silver',
      title: 'Perfect Silver',
      category: BadgeCategory.perfection,
      icon: Symbols.thumb_up,
      flavor: 'Twenty-five clean pages.',
      requirement: 'Achieve 25 Perfect Days.',
      progressKind: ProgressKind.cumulative,
      targetValue: 25,
    ),
    BadgeDefinition(
      key: 'perfect_two_hundred',
      title: 'Perfect Two Hundred',
      category: BadgeCategory.perfection,
      icon: Symbols.hotel_class,
      flavor: 'Two hundred flawless.',
      requirement: 'Achieve 200 Perfect Days.',
      progressKind: ProgressKind.cumulative,
      targetValue: 200,
    ),
    BadgeDefinition(
      key: 'perfect_year',
      title: 'Perfect Year',
      category: BadgeCategory.perfection,
      icon: Symbols.stars,
      flavor: 'A year of clean pages.',
      requirement: 'Achieve 365 Perfect Days.',
      progressKind: ProgressKind.cumulative,
      targetValue: 365,
    ),
    BadgeDefinition(
      key: 'flawless_week',
      title: 'Flawless Week',
      category: BadgeCategory.perfection,
      icon: Symbols.task_alt,
      flavor: 'Seven in a row, perfect.',
      requirement: 'Achieve 7 consecutive Perfect Days.',
      progressKind: ProgressKind.peak,
      targetValue: 7,
    ),
    BadgeDefinition(
      key: 'flawless_season',
      title: 'Flawless Season',
      category: BadgeCategory.perfection,
      icon: Symbols.spa,
      flavor: 'Thirty days, no asterisks.',
      requirement: 'Achieve 30 consecutive Perfect Days.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),

    // ── 4. GOALS (8) ──────────────────────────────────────────────────────────
    BadgeDefinition(
      key: 'goal_getter',
      title: 'Goal Getter',
      category: BadgeCategory.goals,
      icon: Symbols.flag,
      flavor: 'First chapter closed.',
      requirement: 'Complete 1 overarching goal.',
      progressKind: ProgressKind.cumulative,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'polymath',
      title: 'Polymath',
      category: BadgeCategory.goals,
      icon: Symbols.psychology,
      flavor: 'Five chapters closed.',
      requirement: 'Complete 5 overarching goals.',
      progressKind: ProgressKind.cumulative,
      targetValue: 5,
    ),
    BadgeDefinition(
      key: 'decathlon',
      title: 'Decathlon',
      category: BadgeCategory.goals,
      icon: Symbols.sports_score,
      flavor: 'A shelf of finished things.',
      requirement: 'Complete 10 overarching goals.',
      progressKind: ProgressKind.cumulative,
      targetValue: 10,
    ),
    BadgeDefinition(
      key: 'second_chapter',
      title: 'Second Chapter',
      category: BadgeCategory.goals,
      icon: Symbols.book,
      flavor: 'Two chapters closed.',
      requirement: 'Complete 2 overarching goals.',
      progressKind: ProgressKind.cumulative,
      targetValue: 2,
    ),
    BadgeDefinition(
      key: 'trilogy',
      title: 'Trilogy',
      category: BadgeCategory.goals,
      icon: Symbols.library_books,
      flavor: 'Three, beginning to end.',
      requirement: 'Complete 3 overarching goals.',
      progressKind: ProgressKind.cumulative,
      targetValue: 3,
    ),
    BadgeDefinition(
      key: 'lucky_seven_goals',
      title: 'Lucky Seven',
      category: BadgeCategory.goals,
      icon: Symbols.casino,
      flavor: 'Seven ventures finished.',
      requirement: 'Complete 7 overarching goals.',
      progressKind: ProgressKind.cumulative,
      targetValue: 7,
    ),
    BadgeDefinition(
      key: 'fifteen_halls',
      title: 'Fifteen Halls',
      category: BadgeCategory.goals,
      icon: Symbols.corporate_fare,
      flavor: 'Fifteen halls walked.',
      requirement: 'Complete 15 overarching goals.',
      progressKind: ProgressKind.cumulative,
      targetValue: 15,
    ),
    BadgeDefinition(
      key: 'silver_library',
      title: 'Silver Library',
      category: BadgeCategory.goals,
      icon: Symbols.local_library,
      flavor: 'Twenty-five chapters.',
      requirement: 'Complete 25 overarching goals.',
      progressKind: ProgressKind.cumulative,
      targetValue: 25,
    ),

    // ── 5. ECONOMY (8) ────────────────────────────────────────────────────────
    BadgeDefinition(
      key: 'first_freeze',
      title: 'First Freeze',
      category: BadgeCategory.economy,
      icon: Symbols.ac_unit,
      flavor: 'You banked your first mercy.',
      requirement: 'Bank at least 1 streak freeze.',
      progressKind: ProgressKind.cumulative,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'full_pantry',
      title: 'Full Pantry',
      category: BadgeCategory.economy,
      icon: Symbols.inventory_2,
      flavor: 'Two mercies in reserve.',
      requirement: 'Hold 2 streak freezes in your wallet at once.',
      progressKind: ProgressKind.peak,
      targetValue: 2,
    ),
    BadgeDefinition(
      key: 'grace_thrice',
      title: 'Grace Thrice',
      category: BadgeCategory.economy,
      icon: Symbols.volunteer_activism,
      flavor: 'Rescued, and rescued again.',
      requirement: 'Use 3 streak freezes to preserve streaks.',
      progressKind: ProgressKind.cumulative,
      targetValue: 3,
    ),
    BadgeDefinition(
      key: 'first_grace',
      title: 'First Grace',
      category: BadgeCategory.economy,
      icon: Symbols.handshake,
      flavor: 'The first rescue.',
      requirement: 'Use 1 streak freeze to preserve a streak.',
      progressKind: ProgressKind.cumulative,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'grace_fivefold',
      title: 'Grace Fivefold',
      category: BadgeCategory.economy,
      icon: Symbols.diversity_3,
      flavor: 'Five streaks preserved.',
      requirement: 'Use 5 streak freezes to preserve streaks.',
      progressKind: ProgressKind.cumulative,
      targetValue: 5,
    ),
    BadgeDefinition(
      key: 'grace_tenfold',
      title: 'Grace Tenfold',
      category: BadgeCategory.economy,
      icon: Symbols.volunteer_activism,
      flavor: 'Ten times spared.',
      requirement: 'Use 10 streak freezes to preserve streaks.',
      progressKind: ProgressKind.cumulative,
      targetValue: 10,
    ),
    BadgeDefinition(
      key: 'mercy_five',
      title: 'Five Mercies',
      category: BadgeCategory.economy,
      icon: Symbols.ac_unit,
      flavor: 'Five mercies banked.',
      requirement: 'Bank at least 5 streak freezes.',
      progressKind: ProgressKind.cumulative,
      targetValue: 5,
    ),
    BadgeDefinition(
      key: 'mercy_ten',
      title: 'Ten Mercies',
      category: BadgeCategory.economy,
      icon: Symbols.inventory,
      flavor: 'A full winter of mercy.',
      requirement: 'Bank at least 10 streak freezes.',
      progressKind: ProgressKind.cumulative,
      targetValue: 10,
    ),

    // ── 6. RARITIES (11) ──────────────────────────────────────────────────────
    BadgeDefinition(
      key: 'new_years_quest',
      title: "New Year's Quest",
      category: BadgeCategory.rarities,
      icon: Symbols.celebration,
      flavor: 'The year began with a quest.',
      requirement: 'Complete a quest on January 1st.',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'midwinter',
      title: 'Midwinter',
      category: BadgeCategory.rarities,
      icon: Symbols.severe_cold,
      flavor: 'The longest night, kept.',
      requirement: 'Complete a quest on December 21st (Winter Solstice).',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'midsummer',
      title: 'Midsummer',
      category: BadgeCategory.rarities,
      icon: Symbols.wb_sunny,
      flavor: 'The longest day, honored.',
      requirement: 'Complete a quest on June 21st (Summer Solstice).',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'leap_day',
      title: 'Leap Day',
      category: BadgeCategory.rarities,
      icon: Symbols.event,
      flavor: 'Four years in the making.',
      requirement: 'Complete a quest on February 29th.',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'year_one',
      title: 'Year One',
      category: BadgeCategory.rarities,
      icon: Symbols.cake,
      flavor: 'One year on the trail.',
      requirement: 'Log a completion at least 365 days after your very first.',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'unbroken_year',
      title: 'The Unbroken Year',
      category: BadgeCategory.rarities,
      icon: Symbols.all_inclusive,
      flavor: 'Every single day, written.',
      requirement: 'Complete at least 1 quest every day for 365 consecutive days.',
      progressKind: ProgressKind.peak,
      targetValue: 365,
    ),
    BadgeDefinition(
      key: 'spring_equinox',
      title: 'Spring Equinox',
      category: BadgeCategory.rarities,
      icon: Symbols.eco,
      flavor: 'Day and night, balanced.',
      requirement: 'Complete a quest on March 20th (Spring Equinox).',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'autumn_equinox',
      title: 'Autumn Equinox',
      category: BadgeCategory.rarities,
      icon: Symbols.forest,
      flavor: 'The light turns.',
      requirement: 'Complete a quest on September 22nd (Autumn Equinox).',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'hallows',
      title: 'Hallows',
      category: BadgeCategory.rarities,
      icon: Symbols.skull,
      flavor: 'Kept on the thin night.',
      requirement: 'Complete a quest on October 31st.',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'yule',
      title: 'Yule',
      category: BadgeCategory.rarities,
      icon: Symbols.redeem,
      flavor: 'A gift to the log.',
      requirement: 'Complete a quest on December 25th.',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'hearts_day',
      title: "Hearts' Day",
      category: BadgeCategory.rarities,
      icon: Symbols.favorite,
      flavor: 'Kept with love.',
      requirement: 'Complete a quest on February 14th.',
      progressKind: ProgressKind.event,
      targetValue: 1,
    ),

    // ── 7. CALLING — 17 TRIALS ────────────────────────────────────────────────
    BadgeDefinition(
      key: 'trial_iron_will',
      title: 'Iron Will',
      category: BadgeCategory.calling,
      icon: Symbols.fitness_center,
      domain: CallingDomain.warrior,
      flavor: 'The body keeps its word.',
      requirement: 'Reach a 30-period streak on a Warrior quest while pledged to the Warrior.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'trial_hundred_battles',
      title: 'Hundred Battles',
      category: BadgeCategory.calling,
      icon: Symbols.shield,
      domain: CallingDomain.warrior,
      flavor: 'A hundred battles logged.',
      requirement: 'Complete 100 Warrior quests while pledged to the Warrior.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'trial_unbroken_focus',
      title: 'Unbroken Focus',
      category: BadgeCategory.calling,
      icon: Symbols.menu_book,
      domain: CallingDomain.sage,
      flavor: 'The mind holds the line.',
      requirement: 'Reach a 30-period streak on a Sage quest while pledged to the Sage.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'trial_the_archive',
      title: 'The Archive',
      category: BadgeCategory.calling,
      icon: Symbols.auto_stories,
      domain: CallingDomain.sage,
      flavor: 'The archive grows heavy.',
      requirement: 'Complete 100 Sage quests while pledged to the Sage.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'trial_still_water',
      title: 'Still Water',
      category: BadgeCategory.calling,
      icon: Symbols.self_improvement,
      domain: CallingDomain.monk,
      flavor: 'The surface does not ripple.',
      requirement: 'Reach a 30-period streak on a Monk quest while pledged to the Monk.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'trial_the_practice',
      title: 'The Practice',
      category: BadgeCategory.calling,
      icon: Symbols.air,
      domain: CallingDomain.monk,
      flavor: 'Breath, after breath.',
      requirement: 'Complete 100 Monk quests while pledged to the Monk.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'trial_long_refrain',
      title: 'The Long Refrain',
      category: BadgeCategory.calling,
      icon: Symbols.music_note,
      domain: CallingDomain.bard,
      flavor: 'The song refuses to end.',
      requirement: 'Reach a 30-period streak on a Bard quest while pledged to the Bard.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'trial_the_repertoire',
      title: 'The Repertoire',
      category: BadgeCategory.calling,
      icon: Symbols.theater_comedy,
      domain: CallingDomain.bard,
      flavor: 'Every stage, played.',
      requirement: 'Complete 100 Bard quests while pledged to the Bard.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'trial_long_trail',
      title: 'The Long Trail',
      category: BadgeCategory.calling,
      icon: Symbols.hiking,
      domain: CallingDomain.ranger,
      flavor: 'The trail goes ever on.',
      requirement: 'Reach a 30-period streak on a Ranger quest while pledged to the Ranger.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'trial_cartographer',
      title: 'The Cartographer',
      category: BadgeCategory.calling,
      icon: Symbols.explore,
      domain: CallingDomain.ranger,
      flavor: 'The map fills in.',
      requirement: 'Complete 100 Ranger quests while pledged to the Ranger.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'trial_steady_hands',
      title: 'Steady Hands',
      category: BadgeCategory.calling,
      icon: Symbols.handyman,
      domain: CallingDomain.artificer,
      flavor: 'The hands do not shake.',
      requirement: 'Reach a 30-period streak on an Artificer quest while pledged to the Artificer.',
      progressKind: ProgressKind.peak,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'trial_masterwork',
      title: 'Masterwork',
      category: BadgeCategory.calling,
      icon: Symbols.construction,
      domain: CallingDomain.artificer,
      flavor: 'Built, and built again.',
      requirement: 'Complete 100 Artificer quests while pledged to the Artificer.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'first_tribute',
      title: 'First Tribute',
      category: BadgeCategory.calling,
      icon: Symbols.swords,
      flavor: 'The first offering.',
      requirement: 'Complete 1 quest of your pledged calling.',
      progressKind: ProgressKind.cumulative,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'oathkeeper',
      title: 'Oathkeeper',
      category: BadgeCategory.calling,
      icon: Symbols.gavel,
      flavor: 'Twenty-five, in your colors.',
      requirement: 'Complete 25 quests of your pledged calling.',
      progressKind: ProgressKind.cumulative,
      targetValue: 25,
    ),
    BadgeDefinition(
      key: 'paragon',
      title: 'Paragon',
      category: BadgeCategory.calling,
      icon: Symbols.anchor,
      flavor: 'Two hundred fifty, unwavering.',
      requirement: 'Complete 250 quests of your pledged calling.',
      progressKind: ProgressKind.cumulative,
      targetValue: 250,
    ),
    BadgeDefinition(
      key: 'unbending',
      title: 'Unbending',
      category: BadgeCategory.calling,
      icon: Symbols.account_balance,
      flavor: 'Sixty periods, unbroken.',
      requirement: 'Reach a 60-period streak on a quest of your pledged calling.',
      progressKind: ProgressKind.peak,
      targetValue: 60,
    ),
    BadgeDefinition(
      key: 'full_circle',
      title: 'Full Circle',
      category: BadgeCategory.calling,
      icon: Symbols.all_inclusive,
      flavor: 'Every road, walked once.',
      requirement: 'Complete at least 1 quest in all six callings.',
      progressKind: ProgressKind.cumulative,
      targetValue: 6,
    ),

    // ── 8. KEEPER (10) ────────────────────────────────────────────────────────
    BadgeDefinition(
      key: 'keeper_first_day',
      title: 'First Day Together',
      category: BadgeCategory.keeper,
      icon: Symbols.pets,
      flavor: 'It watched its first day happen.',
      requirement: 'Log a completion on any day.',
      progressKind: ProgressKind.cumulative,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'keeper_first_watch',
      title: 'First Watch',
      category: BadgeCategory.keeper,
      icon: Symbols.visibility,
      flavor: 'The first perfect day, witnessed.',
      requirement: 'Achieve 1 Perfect Day.',
      progressKind: ProgressKind.cumulative,
      targetValue: 1,
    ),
    BadgeDefinition(
      key: 'keeper_waking',
      title: 'Waking',
      category: BadgeCategory.keeper,
      icon: Symbols.alarm,
      flavor: 'Ten perfect days. It stirs.',
      requirement: 'Achieve 10 Perfect Days (the Keeper wakes).',
      progressKind: ProgressKind.cumulative,
      targetValue: 10,
    ),
    BadgeDefinition(
      key: 'keeper_adorned',
      title: 'Adorned',
      category: BadgeCategory.keeper,
      icon: Symbols.candle,
      flavor: 'Thirty. It shines a little.',
      requirement: 'Achieve 30 Perfect Days (the Keeper is adorned).',
      progressKind: ProgressKind.cumulative,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'keeper_trimmed',
      title: 'Trimmed',
      category: BadgeCategory.keeper,
      icon: Symbols.bolt,
      flavor: 'A hundred. Ember at the edges.',
      requirement: 'Achieve 100 Perfect Days (the Keeper is trimmed).',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
    ),
    BadgeDefinition(
      key: 'keeper_company_week',
      title: 'A Week of Company',
      category: BadgeCategory.keeper,
      icon: Symbols.groups,
      flavor: 'Seven days kept company.',
      requirement: 'Log completions on 7 distinct days.',
      progressKind: ProgressKind.cumulative,
      targetValue: 7,
    ),
    BadgeDefinition(
      key: 'keeper_company_season',
      title: 'A Season of Company',
      category: BadgeCategory.keeper,
      icon: Symbols.calendar_month,
      flavor: 'Thirty days together.',
      requirement: 'Log completions on 30 distinct days.',
      progressKind: ProgressKind.cumulative,
      targetValue: 30,
    ),
    BadgeDefinition(
      key: 'keeper_company_year',
      title: 'A Year of Company',
      category: BadgeCategory.keeper,
      icon: Symbols.public,
      flavor: 'A full year, side by side.',
      requirement: 'Log completions on 365 distinct days.',
      progressKind: ProgressKind.cumulative,
      targetValue: 365,
    ),
    BadgeDefinition(
      key: 'keeper_level_ten',
      title: 'Level Ten',
      category: BadgeCategory.keeper,
      icon: Symbols.trending_up,
      flavor: 'Double digits. It stands taller.',
      requirement: 'Reach player level 10.',
      progressKind: ProgressKind.cumulative,
      targetValue: 10,
    ),
    BadgeDefinition(
      key: 'keeper_legend',
      title: 'Legend',
      category: BadgeCategory.keeper,
      icon: Symbols.hotel_class,
      flavor: 'Level thirty. The golden face.',
      requirement: 'Reach player level 30 (the Keeper is gilded).',
      progressKind: ProgressKind.cumulative,
      targetValue: 30,
    ),

    // ── 9. SEALED (12) ────────────────────────────────────────────────────────
    BadgeDefinition(
      key: 'night_owl',
      title: 'Night Owl',
      category: BadgeCategory.sealed,
      icon: Symbols.bedtime,
      flavor: 'Logged while the world slept.',
      requirement: 'Log a completion between midnight and 05:00.',
      progressKind: ProgressKind.event,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'dawnbreaker',
      title: 'Dawnbreaker',
      category: BadgeCategory.sealed,
      icon: Symbols.wb_twilight,
      flavor: 'Finished before the sun.',
      requirement: 'Log a completion before 07:00 in the morning.',
      progressKind: ProgressKind.event,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'historian',
      title: 'The Historian',
      category: BadgeCategory.sealed,
      icon: Symbols.history,
      flavor: 'The past, honestly kept.',
      requirement: 'Log 25 backfilled completions.',
      progressKind: ProgressKind.cumulative,
      targetValue: 25,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'scribe',
      title: 'The Scribe',
      category: BadgeCategory.sealed,
      icon: Symbols.edit_note,
      flavor: 'Fifty entries with words attached.',
      requirement: 'Attach notes to 50 quest completions.',
      progressKind: ProgressKind.cumulative,
      targetValue: 50,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'perfectionist',
      title: 'Perfectionist',
      category: BadgeCategory.sealed,
      icon: Symbols.grade,
      flavor: 'Flawless, and it stayed flawless.',
      requirement: 'Achieve 14 consecutive Perfect Days.',
      progressKind: ProgressKind.peak,
      targetValue: 14,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'curator',
      title: 'The Curator',
      category: BadgeCategory.sealed,
      icon: Symbols.museum,
      flavor: 'Kept what mattered, retired the rest.',
      requirement: 'Archive 5 quests that had reached at least 90% completion.',
      progressKind: ProgressKind.cumulative,
      targetValue: 5,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'marathon_day',
      title: 'Marathon Day',
      category: BadgeCategory.sealed,
      icon: Symbols.directions_run,
      flavor: 'One very full page.',
      requirement: 'Log 12 or more completions on a single calendar day.',
      progressKind: ProgressKind.peak,
      targetValue: 12,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'nightcap',
      title: 'Nightcap',
      category: BadgeCategory.sealed,
      icon: Symbols.moon_stars,
      flavor: 'One last entry before sleep.',
      requirement: 'Log a completion between 22:00 and midnight.',
      progressKind: ProgressKind.event,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'high_noon',
      title: 'High Noon',
      category: BadgeCategory.sealed,
      icon: Symbols.light_mode,
      flavor: 'Kept at midday.',
      requirement: 'Log a completion between 12:00 and 13:00.',
      progressKind: ProgressKind.event,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'century_backfill',
      title: 'Century Backfill',
      category: BadgeCategory.sealed,
      icon: Symbols.update,
      flavor: 'A hundred honest corrections.',
      requirement: 'Log 100 backfilled completions.',
      progressKind: ProgressKind.cumulative,
      targetValue: 100,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'annalist',
      title: 'Annalist',
      category: BadgeCategory.sealed,
      icon: Symbols.border_color,
      flavor: 'Two hundred fifty entries with words.',
      requirement: 'Attach notes to 250 quest completions.',
      progressKind: ProgressKind.cumulative,
      targetValue: 250,
      sealed: true,
    ),
    BadgeDefinition(
      key: 'grand_marathon',
      title: 'Grand Marathon',
      category: BadgeCategory.sealed,
      icon: Symbols.rocket_launch,
      flavor: 'Twenty-five in a single day.',
      requirement: 'Log 25 or more completions on a single calendar day.',
      progressKind: ProgressKind.peak,
      targetValue: 25,
      sealed: true,
    ),
  ];

  /// Pure deterministic evaluation of all 100 badges based on the SQLite logbook state.
  /// Freeze grants derive from the completion log itself (see [FreezeEngine]);
  /// perfect-week ledger events are XP-only and intentionally not read here.
  static List<BadgeStatus> evaluate({
    required List<CompletionData> completions,
    required List<QuestData> quests,
    required List<GoalData> goals,
    required List<StreakRepairData> streakRepairs,
    required ProfileData profile,
    required Map<String, int> questMaxStreaks,
    required Set<LocalDate> perfectDays,
    required Set<String> seenBadgeKeys,
    required WeekStart weekStart,
    required LocalDate today,
    int playerLevel = 1,
  }) {
    final questMap = {for (final q in quests) q.id: q};
    final userCalling = profile.calling != null ? CallingDomain.values[profile.calling!] : null;

    // ── Pre-calculations ────────────────────────────────────────────────────
    final totalCompletionsCount = completions.fold<int>(0, (sum, c) => sum + c.value);

    // Max streak across all quests
    int maxAnyStreak = 0;
    int maxWeeklyStreak = 0;
    int maxMonthlyStreak = 0;
    int maxYearlyStreak = 0;
    final maxStreakByDomain = <CallingDomain, int>{};

    for (final entry in questMaxStreaks.entries) {
      final q = questMap[entry.key];
      final s = entry.value;
      if (s > maxAnyStreak) maxAnyStreak = s;

      if (q != null) {
        if (q.rule.cadence == Cadence.weekly && s > maxWeeklyStreak) maxWeeklyStreak = s;
        if (q.rule.cadence == Cadence.monthly && s > maxMonthlyStreak) maxMonthlyStreak = s;
        if (q.rule.cadence == Cadence.yearly && s > maxYearlyStreak) maxYearlyStreak = s;

        if (q.domain != null) {
          final d = CallingDomain.values[q.domain!];
          if (s > (maxStreakByDomain[d] ?? 0)) {
            maxStreakByDomain[d] = s;
          }
        }
      }
    }

    // Domain completions count
    final domainCompletionsCount = <CallingDomain, int>{};
    for (final c in completions) {
      final q = questMap[c.questId];
      if (q != null && q.domain != null) {
        final d = CallingDomain.values[q.domain!];
        domainCompletionsCount[d] = (domainCompletionsCount[d] ?? 0) + c.value;
      }
    }

    // Goals completed
    final completedGoalsCount = goals.where((g) => g.completedAt != null).length;

    // Perfect days count & longest consecutive run
    final perfectDaysList = perfectDays.toList()..sort();
    final perfectDaysCount = perfectDaysList.length;

    int maxConsecutivePerfectDays = 0;
    if (perfectDaysList.isNotEmpty) {
      int currentRun = 1;
      maxConsecutivePerfectDays = 1;
      for (int i = 1; i < perfectDaysList.length; i++) {
        final prev = perfectDaysList[i - 1];
        final curr = perfectDaysList[i];
        if (curr.differenceInDays(prev) == 1) {
          currentRun++;
          if (currentRun > maxConsecutivePerfectDays) {
            maxConsecutivePerfectDays = currentRun;
          }
        } else {
          currentRun = 1;
        }
      }
    }

    // Freeze grants derive from the log — the single source shared with the
    // live wallet (2 per perfect daily/weekly week, 1 per essentials-only
    // week). Ledger perfect-week events are XP-only artifacts, not counted.
    final completionsByQuestForFreezes = <String, Map<LocalDate, int>>{};
    for (final c in completions) {
      final d = LocalDate.parse(c.localDate);
      completionsByQuestForFreezes.putIfAbsent(c.questId, () => <LocalDate, int>{})[d] =
          (completionsByQuestForFreezes[c.questId]![d] ?? 0) + c.value;
    }
    final freezeWeekly = FreezeEngine.weeklyGrants(
      quests: quests,
      completionsByQuest: completionsByQuestForFreezes,
      weekStart: weekStart,
      today: today,
    );
    var freezeGrantsTotal = 0;
    var perfectWeeksCount = 0;
    for (final g in freezeWeekly) {
      freezeGrantsTotal += g.grants;
      if (g.grants >= 2) perfectWeeksCount++;
    }
    final freezePeak =
        FreezeEngine.peakWallet(grants: freezeWeekly, repairs: streakRepairs);
    final freezeBalance = FreezeEngine.replayWallet(
        grants: freezeWeekly, repairs: streakRepairs);

    // Economy: repairs persist via consume-on-write.
    int streakRepairsCount = streakRepairs.length;

    // Perfect calendar month check (every eligible day in a month perfect, with >= 20 eligible days)
    bool hasPerfectMonth = false;
    final perfectDaysByMonth = <String, Set<int>>{};
    for (final pd in perfectDays) {
      final key = '${pd.year}-${pd.month.toString().padLeft(2, '0')}';
      perfectDaysByMonth.putIfAbsent(key, () => {}).add(pd.day);
    }
    for (final entry in perfectDaysByMonth.entries) {
      if (entry.value.length >= 20) {
        hasPerfectMonth = true;
        break;
      }
    }

    // (Freeze pre-calcs live above, next to perfectWeeksCount.)

    // Rarities calculations
    bool hasJan1 = false;
    bool hasDec21 = false;
    bool hasJun21 = false;
    bool hasFeb29 = false;
    bool hasYearOne = false;
    bool hasMar20 = false;
    bool hasSep22 = false;
    bool hasOct31 = false;
    bool hasDec25 = false;
    bool hasFeb14 = false;
    LocalDate? firstCompletionDate;

    final distinctDates = <LocalDate>{};
    final completionsByDateCount = <LocalDate, int>{};

    for (final c in completions) {
      final d = LocalDate.parse(c.localDate);
      distinctDates.add(d);
      completionsByDateCount[d] = (completionsByDateCount[d] ?? 0) + c.value;

      if (d.month == 1 && d.day == 1) hasJan1 = true;
      if (d.month == 12 && d.day == 21) hasDec21 = true;
      if (d.month == 6 && d.day == 21) hasJun21 = true;
      if (d.month == 2 && d.day == 29) hasFeb29 = true;
      if (d.month == 3 && d.day == 20) hasMar20 = true;
      if (d.month == 9 && d.day == 22) hasSep22 = true;
      if (d.month == 10 && d.day == 31) hasOct31 = true;
      if (d.month == 12 && d.day == 25) hasDec25 = true;
      if (d.month == 2 && d.day == 14) hasFeb14 = true;

      if (firstCompletionDate == null || d < firstCompletionDate) {
        firstCompletionDate = d;
      }
    }
    final distinctDatesCount = distinctDates.length;

    if (firstCompletionDate != null) {
      for (final d in distinctDates) {
        if (d.differenceInDays(firstCompletionDate) >= 365) {
          hasYearOne = true;
          break;
        }
      }
    }

    // Consecutive active days (Unbroken Year)
    final sortedDates = distinctDates.toList()..sort();
    int maxConsecutiveActiveDays = 0;
    if (sortedDates.isNotEmpty) {
      int currentRun = 1;
      maxConsecutiveActiveDays = 1;
      for (int i = 1; i < sortedDates.length; i++) {
        if (sortedDates[i].differenceInDays(sortedDates[i - 1]) == 1) {
          currentRun++;
          if (currentRun > maxConsecutiveActiveDays) {
            maxConsecutiveActiveDays = currentRun;
          }
        } else {
          currentRun = 1;
        }
      }
    }

    // Sealed pre-calculations
    bool hasNightOwl = false;
    bool hasDawnbreaker = false;
    bool hasNightcap = false;
    bool hasHighNoon = false;
    int backfilledCount = 0;
    int notesCount = 0;
    int maxCompletionsInOneDay = 0;

    for (final c in completions) {
      final hour = c.createdAt.hour;
      if (hour >= 0 && hour < 5) hasNightOwl = true;
      if (hour < 7) hasDawnbreaker = true;
      if (hour >= 22) hasNightcap = true;
      if (hour == 12) hasHighNoon = true;

      final localDate = LocalDate.parse(c.localDate);
      final createdLocalDate = LocalDate.fromDateTime(c.createdAt);
      if (localDate < createdLocalDate) {
        backfilledCount += c.value;
      }

      if (c.note != null && c.note!.trim().isNotEmpty) {
        notesCount++;
      }
    }

    for (final count in completionsByDateCount.values) {
      if (count > maxCompletionsInOneDay) {
        maxCompletionsInOneDay = count;
      }
    }

    // Curator: >= 5 quests archived
    int archivedQuestsCount = quests.where((q) => q.archivedAt != null).length;

    // Calling breadth + pledged-domain devotion
    final domainsWithCompletions =
        domainCompletionsCount.values.where((v) => v >= 1).length;
    final pledgedCompletions =
        userCalling != null ? (domainCompletionsCount[userCalling] ?? 0) : 0;
    final pledgedStreak =
        userCalling != null ? (maxStreakByDomain[userCalling] ?? 0) : 0;

    // ── Evaluate all catalog badges ─────────────────────────────────────────
    return catalog.map((b) {
      bool earned = seenBadgeKeys.contains('badge:${b.key}') || seenBadgeKeys.contains(b.key);
      int currentVal = 0;
      bool eligible = true;

      switch (b.key) {
        // JOURNEY
        case 'first_step':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 1;
          break;
        case 'tenfold':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 10;
          break;
        case 'half_century':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 50;
          break;
        case 'century':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 100;
          break;
        case 'millennial':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 1000;
          break;
        case 'long_log':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 5000;
          break;
        case 'twenty_five':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 25;
          break;
        case 'quarter_thousand':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 250;
          break;
        case 'half_thousand':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 500;
          break;
        case 'two_thousand':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 2000;
          break;
        case 'ten_thousand':
          currentVal = totalCompletionsCount;
          earned = earned || currentVal >= 10000;
          break;

        // STREAKS
        case 'weeks_worth':
          currentVal = maxAnyStreak;
          earned = earned || currentVal >= 7;
          break;
        case 'month_iron':
          currentVal = maxAnyStreak;
          earned = earned || currentVal >= 30;
          break;
        case 'streak_centurion':
          currentVal = maxAnyStreak;
          earned = earned || currentVal >= 100;
          break;
        case 'long_year':
          currentVal = maxAnyStreak;
          earned = earned || currentVal >= 365;
          break;
        case 'thirty_weeks':
          currentVal = maxWeeklyStreak;
          earned = earned || currentVal >= 30;
          break;
        case 'dozen_moons':
          currentVal = maxMonthlyStreak;
          earned = earned || currentVal >= 12;
          break;
        case 'three_ages':
          currentVal = maxYearlyStreak;
          earned = earned || currentVal >= 3;
          break;
        case 'fortnight_fire':
          currentVal = maxAnyStreak;
          earned = earned || currentVal >= 14;
          break;
        case 'fifty_stack':
          currentVal = maxAnyStreak;
          earned = earned || currentVal >= 50;
          break;
        case 'double_century':
          currentVal = maxAnyStreak;
          earned = earned || currentVal >= 200;
          break;
        case 'twelve_weeks':
          currentVal = maxWeeklyStreak;
          earned = earned || currentVal >= 12;
          break;
        case 'half_year_moons':
          currentVal = maxMonthlyStreak;
          earned = earned || currentVal >= 6;
          break;

        // PERFECTION
        case 'perfect_ten':
          currentVal = perfectDaysCount;
          earned = earned || currentVal >= 10;
          break;
        case 'fifty_flawless':
          currentVal = perfectDaysCount;
          earned = earned || currentVal >= 50;
          break;
        case 'perfect_hundred':
          currentVal = perfectDaysCount;
          earned = earned || currentVal >= 100;
          break;
        case 'first_perfect_week':
          currentVal = perfectWeeksCount;
          earned = earned || currentVal >= 1;
          break;
        case 'flawless_fortnight':
          currentVal = maxConsecutivePerfectDays;
          earned = earned || currentVal >= 14;
          break;
        case 'perfect_month':
          currentVal = hasPerfectMonth ? 1 : 0;
          earned = earned || hasPerfectMonth;
          break;
        case 'perfect_silver':
          currentVal = perfectDaysCount;
          earned = earned || currentVal >= 25;
          break;
        case 'perfect_two_hundred':
          currentVal = perfectDaysCount;
          earned = earned || currentVal >= 200;
          break;
        case 'perfect_year':
          currentVal = perfectDaysCount;
          earned = earned || currentVal >= 365;
          break;
        case 'flawless_week':
          currentVal = maxConsecutivePerfectDays;
          earned = earned || currentVal >= 7;
          break;
        case 'flawless_season':
          currentVal = maxConsecutivePerfectDays;
          earned = earned || currentVal >= 30;
          break;

        // GOALS
        case 'goal_getter':
          currentVal = completedGoalsCount;
          earned = earned || currentVal >= 1;
          break;
        case 'polymath':
          currentVal = completedGoalsCount;
          earned = earned || currentVal >= 5;
          break;
        case 'decathlon':
          currentVal = completedGoalsCount;
          earned = earned || currentVal >= 10;
          break;
        case 'second_chapter':
          currentVal = completedGoalsCount;
          earned = earned || currentVal >= 2;
          break;
        case 'trilogy':
          currentVal = completedGoalsCount;
          earned = earned || currentVal >= 3;
          break;
        case 'lucky_seven_goals':
          currentVal = completedGoalsCount;
          earned = earned || currentVal >= 7;
          break;
        case 'fifteen_halls':
          currentVal = completedGoalsCount;
          earned = earned || currentVal >= 15;
          break;
        case 'silver_library':
          currentVal = completedGoalsCount;
          earned = earned || currentVal >= 25;
          break;

        // ECONOMY
        case 'first_freeze':
          currentVal = freezeGrantsTotal;
          earned = earned || currentVal >= 1;
          break;
        case 'full_pantry':
          currentVal = freezePeak >= 2 ? 2 : freezeBalance;
          earned = earned || freezePeak >= 2;
          break;
        case 'grace_thrice':
          currentVal = streakRepairsCount;
          earned = earned || currentVal >= 3;
          break;
        case 'first_grace':
          currentVal = streakRepairsCount;
          earned = earned || currentVal >= 1;
          break;
        case 'grace_fivefold':
          currentVal = streakRepairsCount;
          earned = earned || currentVal >= 5;
          break;
        case 'grace_tenfold':
          currentVal = streakRepairsCount;
          earned = earned || currentVal >= 10;
          break;
        case 'mercy_five':
          currentVal = freezeGrantsTotal;
          earned = earned || currentVal >= 5;
          break;
        case 'mercy_ten':
          currentVal = freezeGrantsTotal;
          earned = earned || currentVal >= 10;
          break;

        // RARITIES
        case 'new_years_quest':
          currentVal = hasJan1 ? 1 : 0;
          earned = earned || hasJan1;
          break;
        case 'midwinter':
          currentVal = hasDec21 ? 1 : 0;
          earned = earned || hasDec21;
          break;
        case 'midsummer':
          currentVal = hasJun21 ? 1 : 0;
          earned = earned || hasJun21;
          break;
        case 'leap_day':
          currentVal = hasFeb29 ? 1 : 0;
          earned = earned || hasFeb29;
          break;
        case 'year_one':
          currentVal = hasYearOne ? 1 : 0;
          earned = earned || hasYearOne;
          break;
        case 'unbroken_year':
          currentVal = maxConsecutiveActiveDays;
          earned = earned || currentVal >= 365;
          break;
        case 'spring_equinox':
          currentVal = hasMar20 ? 1 : 0;
          earned = earned || hasMar20;
          break;
        case 'autumn_equinox':
          currentVal = hasSep22 ? 1 : 0;
          earned = earned || hasSep22;
          break;
        case 'hallows':
          currentVal = hasOct31 ? 1 : 0;
          earned = earned || hasOct31;
          break;
        case 'yule':
          currentVal = hasDec25 ? 1 : 0;
          earned = earned || hasDec25;
          break;
        case 'hearts_day':
          currentVal = hasFeb14 ? 1 : 0;
          earned = earned || hasFeb14;
          break;

        // CALLING TRIALS
        case 'trial_iron_will':
          eligible = userCalling == CallingDomain.warrior;
          currentVal = maxStreakByDomain[CallingDomain.warrior] ?? 0;
          earned = earned || (eligible && currentVal >= 30);
          break;
        case 'trial_hundred_battles':
          eligible = userCalling == CallingDomain.warrior;
          currentVal = domainCompletionsCount[CallingDomain.warrior] ?? 0;
          earned = earned || (eligible && currentVal >= 100);
          break;
        case 'trial_unbroken_focus':
          eligible = userCalling == CallingDomain.sage;
          currentVal = maxStreakByDomain[CallingDomain.sage] ?? 0;
          earned = earned || (eligible && currentVal >= 30);
          break;
        case 'trial_the_archive':
          eligible = userCalling == CallingDomain.sage;
          currentVal = domainCompletionsCount[CallingDomain.sage] ?? 0;
          earned = earned || (eligible && currentVal >= 100);
          break;
        case 'trial_still_water':
          eligible = userCalling == CallingDomain.monk;
          currentVal = maxStreakByDomain[CallingDomain.monk] ?? 0;
          earned = earned || (eligible && currentVal >= 30);
          break;
        case 'trial_the_practice':
          eligible = userCalling == CallingDomain.monk;
          currentVal = domainCompletionsCount[CallingDomain.monk] ?? 0;
          earned = earned || (eligible && currentVal >= 100);
          break;
        case 'trial_long_refrain':
          eligible = userCalling == CallingDomain.bard;
          currentVal = maxStreakByDomain[CallingDomain.bard] ?? 0;
          earned = earned || (eligible && currentVal >= 30);
          break;
        case 'trial_the_repertoire':
          eligible = userCalling == CallingDomain.bard;
          currentVal = domainCompletionsCount[CallingDomain.bard] ?? 0;
          earned = earned || (eligible && currentVal >= 100);
          break;
        case 'trial_long_trail':
          eligible = userCalling == CallingDomain.ranger;
          currentVal = maxStreakByDomain[CallingDomain.ranger] ?? 0;
          earned = earned || (eligible && currentVal >= 30);
          break;
        case 'trial_cartographer':
          eligible = userCalling == CallingDomain.ranger;
          currentVal = domainCompletionsCount[CallingDomain.ranger] ?? 0;
          earned = earned || (eligible && currentVal >= 100);
          break;
        case 'trial_steady_hands':
          eligible = userCalling == CallingDomain.artificer;
          currentVal = maxStreakByDomain[CallingDomain.artificer] ?? 0;
          earned = earned || (eligible && currentVal >= 30);
          break;
        case 'trial_masterwork':
          eligible = userCalling == CallingDomain.artificer;
          currentVal = domainCompletionsCount[CallingDomain.artificer] ?? 0;
          earned = earned || (eligible && currentVal >= 100);
          break;
        case 'first_tribute':
          eligible = userCalling != null;
          currentVal = pledgedCompletions;
          earned = earned || (eligible && currentVal >= 1);
          break;
        case 'oathkeeper':
          eligible = userCalling != null;
          currentVal = pledgedCompletions;
          earned = earned || (eligible && currentVal >= 25);
          break;
        case 'paragon':
          eligible = userCalling != null;
          currentVal = pledgedCompletions;
          earned = earned || (eligible && currentVal >= 250);
          break;
        case 'unbending':
          eligible = userCalling != null;
          currentVal = pledgedStreak;
          earned = earned || (eligible && currentVal >= 60);
          break;
        case 'full_circle':
          currentVal = domainsWithCompletions;
          earned = earned || currentVal >= 6;
          break;

        // KEEPER
        case 'keeper_first_day':
          currentVal = distinctDatesCount;
          earned = earned || currentVal >= 1;
          break;
        case 'keeper_first_watch':
          currentVal = perfectDaysCount;
          earned = earned || currentVal >= 1;
          break;
        case 'keeper_waking':
          currentVal = perfectDaysCount;
          earned = earned || currentVal >= KeeperTunables.growthWaking;
          break;
        case 'keeper_adorned':
          currentVal = perfectDaysCount;
          earned = earned || currentVal >= KeeperTunables.growthAdorned;
          break;
        case 'keeper_trimmed':
          currentVal = perfectDaysCount;
          earned = earned || currentVal >= KeeperTunables.growthTrimmed;
          break;
        case 'keeper_company_week':
          currentVal = distinctDatesCount;
          earned = earned || currentVal >= 7;
          break;
        case 'keeper_company_season':
          currentVal = distinctDatesCount;
          earned = earned || currentVal >= 30;
          break;
        case 'keeper_company_year':
          currentVal = distinctDatesCount;
          earned = earned || currentVal >= 365;
          break;
        case 'keeper_level_ten':
          currentVal = playerLevel;
          earned = earned || currentVal >= 10;
          break;
        case 'keeper_legend':
          currentVal = playerLevel;
          earned = earned || currentVal >= KeeperTunables.gildLevel;
          break;

        // SEALED
        case 'night_owl':
          currentVal = hasNightOwl ? 1 : 0;
          earned = earned || hasNightOwl;
          break;
        case 'dawnbreaker':
          currentVal = hasDawnbreaker ? 1 : 0;
          earned = earned || hasDawnbreaker;
          break;
        case 'historian':
          currentVal = backfilledCount;
          earned = earned || currentVal >= 25;
          break;
        case 'scribe':
          currentVal = notesCount;
          earned = earned || currentVal >= 50;
          break;
        case 'perfectionist':
          currentVal = maxConsecutivePerfectDays;
          earned = earned || currentVal >= 14;
          break;
        case 'curator':
          currentVal = archivedQuestsCount;
          earned = earned || currentVal >= 5;
          break;
        case 'marathon_day':
          currentVal = maxCompletionsInOneDay;
          earned = earned || currentVal >= 12;
          break;
        case 'nightcap':
          currentVal = hasNightcap ? 1 : 0;
          earned = earned || hasNightcap;
          break;
        case 'high_noon':
          currentVal = hasHighNoon ? 1 : 0;
          earned = earned || hasHighNoon;
          break;
        case 'century_backfill':
          currentVal = backfilledCount;
          earned = earned || currentVal >= 100;
          break;
        case 'annalist':
          currentVal = notesCount;
          earned = earned || currentVal >= 250;
          break;
        case 'grand_marathon':
          currentVal = maxCompletionsInOneDay;
          earned = earned || currentVal >= 25;
          break;
      }

      return BadgeStatus(
        definition: b,
        isEarned: earned,
        currentValue: currentVal,
        isEligible: eligible,
      );
    }).toList();
  }
}

