import 'package:flutter/material.dart';

import '../models/achievement.dart';

class AchievementsCatalog {
  AchievementsCatalog._();

  static const List<Achievement> all = [
    // ── Lessons completed ──
    Achievement(
      id: 'first_steps',
      title: 'First Steps',
      description: 'Complete your first lesson.',
      icon: Icons.flag_outlined,
      color: Color(0xFF00B894),
      xpReward: 20,
      conditionType: AchievementCondition.lessonsCompleted,
      targetValue: 1,
    ),
    Achievement(
      id: 'studious',
      title: 'Studious',
      description: 'Complete 5 lessons.',
      icon: Icons.menu_book_outlined,
      color: Color(0xFF6C5CE7),
      xpReward: 50,
      conditionType: AchievementCondition.lessonsCompleted,
      targetValue: 5,
    ),
    Achievement(
      id: 'scholar',
      title: 'Scholar',
      description: 'Complete every lesson on the roadmap.',
      icon: Icons.school_outlined,
      color: Color(0xFFFFB020),
      xpReward: 200,
      conditionType: AchievementCondition.lessonsCompleted,
      targetValue: 11,
    ),

    // ── Challenges completed ──
    Achievement(
      id: 'code_challenger',
      title: 'Code Challenger',
      description: 'Pass your first challenge.',
      icon: Icons.terminal,
      color: Color(0xFF0984E3),
      xpReward: 20,
      conditionType: AchievementCondition.challengesCompleted,
      targetValue: 1,
    ),
    Achievement(
      id: 'problem_solver',
      title: 'Problem Solver',
      description: 'Pass 3 challenges.',
      icon: Icons.psychology_outlined,
      color: Color(0xFF0984E3),
      xpReward: 50,
      conditionType: AchievementCondition.challengesCompleted,
      targetValue: 3,
    ),
    Achievement(
      id: 'master_coder',
      title: 'Master Coder',
      description: 'Pass every challenge.',
      icon: Icons.workspace_premium_outlined,
      color: Color(0xFFFFB020),
      xpReward: 200,
      conditionType: AchievementCondition.challengesCompleted,
      targetValue: 6,
    ),

    // ── Projects created ──
    Achievement(
      id: 'creator',
      title: 'Creator',
      description: 'Save your first project.',
      icon: Icons.create_outlined,
      color: Color(0xFFE17055),
      xpReward: 20,
      conditionType: AchievementCondition.projectsCreated,
      targetValue: 1,
    ),
    Achievement(
      id: 'builder',
      title: 'Builder',
      description: 'Save 5 projects.',
      icon: Icons.construction_outlined,
      color: Color(0xFFE17055),
      xpReward: 50,
      conditionType: AchievementCondition.projectsCreated,
      targetValue: 5,
    ),
    Achievement(
      id: 'prolific',
      title: 'Prolific',
      description: 'Save 10 projects.',
      icon: Icons.folder_special_outlined,
      color: Color(0xFFE17055),
      xpReward: 100,
      conditionType: AchievementCondition.projectsCreated,
      targetValue: 10,
    ),

    // ── Streak ──
    Achievement(
      id: 'consistency_3',
      title: 'Consistency',
      description: 'Learn 3 days in a row.',
      icon: Icons.local_fire_department_outlined,
      color: Color(0xFFFF6B35),
      xpReward: 30,
      conditionType: AchievementCondition.streakDays,
      targetValue: 3,
    ),
    Achievement(
      id: 'dedicated_7',
      title: 'Dedicated',
      description: 'Learn 7 days in a row.',
      icon: Icons.local_fire_department,
      color: Color(0xFFFF6B35),
      xpReward: 100,
      conditionType: AchievementCondition.streakDays,
      targetValue: 7,
    ),
    Achievement(
      id: 'unstoppable_30',
      title: 'Unstoppable',
      description: 'Learn 30 days in a row.',
      icon: Icons.bolt,
      color: Color(0xFFFFB020),
      xpReward: 300,
      conditionType: AchievementCondition.streakDays,
      targetValue: 30,
    ),

    // ── XP total ──
    Achievement(
      id: 'going_far_500',
      title: 'Going Far',
      description: 'Earn 500 total XP.',
      icon: Icons.star_outline,
      color: Color(0xFF6C5CE7),
      xpReward: 50,
      conditionType: AchievementCondition.xpTotal,
      targetValue: 500,
    ),
    Achievement(
      id: 'expert_1500',
      title: 'Expert',
      description: 'Earn 1500 total XP.',
      icon: Icons.star_half,
      color: Color(0xFF6C5CE7),
      xpReward: 150,
      conditionType: AchievementCondition.xpTotal,
      targetValue: 1500,
    ),

    // ── Daily challenges ──
    Achievement(
      id: 'daily_warrior',
      title: 'Daily Warrior',
      description: 'Complete 7 daily challenges.',
      icon: Icons.bolt_outlined,
      color: Color(0xFFFFB020),
      xpReward: 100,
      conditionType: AchievementCondition.dailyChallengesCompleted,
      targetValue: 7,
    ),

    // ── Mini projects ──
    Achievement(
      id: 'first_project',
      title: 'First Project',
      description: 'Complete your first mini project.',
      icon: Icons.flag_outlined,
      color: Color(0xFFE17055),
      xpReward: 30,
      conditionType: AchievementCondition.miniProjectsCompleted,
      targetValue: 1,
    ),
    Achievement(
      id: 'project_builder',
      title: 'Project Builder',
      description: 'Complete 3 mini projects.',
      icon: Icons.handyman_outlined,
      color: Color(0xFFE17055),
      xpReward: 75,
      conditionType: AchievementCondition.miniProjectsCompleted,
      targetValue: 3,
    ),
    Achievement(
      id: 'project_master',
      title: 'Project Master',
      description: 'Complete every mini project in the track.',
      icon: Icons.architecture_outlined,
      color: Color(0xFFD63031),
      xpReward: 250,
      conditionType: AchievementCondition.miniProjectsCompleted,
      targetValue: 9,
    ),

    // ── Certificates ──
    Achievement(
      id: 'certified_learner',
      title: 'Certified Learner',
      description: 'Earn your first certificate.',
      icon: Icons.verified_outlined,
      color: Color(0xFF6C5CE7),
      xpReward: 50,
      conditionType: AchievementCondition.certificatesEarned,
      targetValue: 1,
    ),
    Achievement(
      id: 'devpath_graduate',
      title: 'DevPath Graduate',
      description: 'Earn every DevPath certificate.',
      icon: Icons.school_outlined,
      color: Color(0xFF6C5CE7),
      xpReward: 500,
      conditionType: AchievementCondition.certificatesEarned,
      targetValue: 4,
    ),
  ];

  static Achievement? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }

  static List<Achievement> byCondition(AchievementCondition c) =>
      all.where((a) => a.conditionType == c).toList();
}
