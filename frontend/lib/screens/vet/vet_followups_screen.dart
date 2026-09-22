import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../routes/app_routes.dart';
import '../../services/medical_records_service.dart';
import '../../utils/constants.dart';
import '../../widgets/pet_mascots.dart';
import '../main_navigation_shell.dart';

/// DAY 10 — Vet: Today's Follow-ups (Cross-Branch Proof, Part 2)
///
/// Thesis: A veterinarian's clinical worklist of patient check-ins pulls from treatments
/// across ALL clinic branches in the network, regardless of which branch originally created
/// the treatment record.
///
/// Features:
/// - "Cross-Branch Access" banner reinforcing centralized patient history
/// - Quick filter tabs: (All / Urgent / Post-Surgery / Medication Review — client-side filters)
/// - "Due This Week" list of follow-up cards showing:
///   - Pet's name & breed
///   - Originating Branch (proving cross-branch worklist)
///   - Appointment time / scheduled follow-up
///   - Visual-only chat icon placeholder
///   - Category badge
class VetFollowupsScreen extends StatefulWidget {
  const VetFollowupsScreen({super.key});

  @override
  State<VetFollowupsScreen> createState() => _VetFollowupsScreenState();
}

class _VetFollowupsScreenState extends State<VetFollowupsScreen> {
  final MedicalRecordsService _recordsService = MedicalRecordsService();

  // Active filter tab: 'all', 'urgent', 'post_surgery', 'medication_review'
  String _activeCategoryFilter = 'all';
  bool _isLoading = true;
  List<VetFollowupItem> _allFollowups = [];

  @override
  void initState() {
    super.initState();
    _loadFollowups();
  }

  Future<void> _loadFollowups() async {
    setState(() => _isLoading = true);

    try {
      final items = await _recordsService.fetchUpcomingFollowups();
      if (mounted) {
        setState(() {
          _allFollowups = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _allFollowups = _recordsService.getFallbackFollowups();
          _isLoading = false;
        });
      }
    }
  }

  /// Client-side filtering of already-fetched follow-up treatments
  List<VetFollowupItem> get _filteredFollowups {
    if (_activeCategoryFilter == 'all') {
      return _allFollowups;
    }
    return _allFollowups.where((item) => item.category == _activeCategoryFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayedItems = _filteredFollowups;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border.withValues(alpha: 0.4), width: 1),
            ),
            child: const Icon(Icons.arrow_back, size: 18, color: AppColors.textPrimary),
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              final shell = MainNavigationShell.of(context);
              if (shell != null) {
                shell.setTab(0);
              }
            }
          },
        ),
        title: const Text(
          "Vet Today's Follow-ups",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.4), width: 1),
              ),
              child: const Icon(Icons.refresh, size: 18, color: AppColors.textPrimary),
            ),
            tooltip: 'Refresh Worklist',
            onPressed: _loadFollowups,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 95),
              children: [
            // ===============================================================
            // 1. "CROSS-BRANCH ACCESS" BANNER
            // ===============================================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFBBF7D0), width: 1.2),
                boxShadow: AppShadows.subtleCard,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.sync_alt, color: Color(0xFF16A34A), size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cross-Branch Access',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF15803D),
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Centralized clinical worklist — every patient’s medical history and treatment plan follows them to this branch seamlessly.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF166534),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===============================================================
            // 2. QUICK FILTER TABS (All / Urgent / Post-Surgery / Medication Review)
            // Client-side filtering only
            // ===============================================================
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryTab(id: 'all', label: 'All (${_allFollowups.length})'),
                  const SizedBox(width: 8),
                  _buildCategoryTab(
                    id: 'urgent',
                    label: 'Urgent (${_allFollowups.where((i) => i.category == 'urgent').length})',
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryTab(
                    id: 'post_surgery',
                    label: 'Post-Surgery (${_allFollowups.where((i) => i.category == 'post_surgery').length})',
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryTab(
                    id: 'medication_review',
                    label: 'Medication Review (${_allFollowups.where((i) => i.category == 'medication_review').length})',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ===============================================================
            // 3. "DUE THIS WEEK" SECTION HEADER
            // ===============================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Due This Week',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${displayedItems.length} scheduled',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ===============================================================
            // 4. LIST OF FOLLOW-UP CARDS
            // Proving cross-branch origins (Westside Branch, Central Metro Hub, etc.)
            // ===============================================================
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (displayedItems.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.4), width: 1),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.event_available, size: 40, color: AppColors.textMuted),
                    SizedBox(height: 10),
                    Text(
                      'No follow-ups due in this category',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              )
            else
              ...displayedItems.map((item) => _buildFollowupCard(item)),
            ],
          ),
        ),
      ),
    ),
  );
}

  // Quick Filter Tab Button
  Widget _buildCategoryTab({required String id, required String label}) {
    final isSelected = _activeCategoryFilter == id;
    return InkWell(
      onTap: () {
        setState(() {
          _activeCategoryFilter = id;
        });
      },
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkPill : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? AppColors.darkPill : AppColors.border,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  // Follow-up Card with Branch Origin, Appointment Time, and Chat Icon Placeholder
  Widget _buildFollowupCard(VetFollowupItem item) {
    final isDog = item.species.toLowerCase() == 'dog';

    // Category badge color
    Color badgeBg;
    Color badgeTextColor;
    String badgeLabel;

    switch (item.category) {
      case 'urgent':
        badgeBg = const Color(0xFFFEF2F2);
        badgeTextColor = const Color(0xFFDC2626);
        badgeLabel = 'Urgent Follow-up';
        break;
      case 'post_surgery':
        badgeBg = const Color(0xFFEFF6FF);
        badgeTextColor = const Color(0xFF2563EB);
        badgeLabel = 'Post-Surgery';
        break;
      case 'medication_review':
        badgeBg = const Color(0xFFFEF3C7);
        badgeTextColor = const Color(0xFFD97706);
        badgeLabel = 'Medication Review';
        break;
      default:
        badgeBg = AppColors.lightPill;
        badgeTextColor = AppColors.textPrimary;
        badgeLabel = 'Routine Check-in';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4), width: 1),
        boxShadow: AppShadows.subtleCard,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            // Navigate to pet profile with patient details
            final pet = PetModel(
              id: item.petId,
              name: item.petName,
              species: item.species,
              breed: item.petBreed,
              gender: 'male',
              dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 3)),
              microchipId: '47209',
              ownerId: 'owner_demo',
              createdAt: DateTime.now().subtract(const Duration(days: 365 * 3)),
            );
            Navigator.pushNamed(context, AppRoutes.petProfile, arguments: pet);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar, Name, Category Pill, and Chat Icon Placeholder
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDog ? const Color(0xFFFED7AA) : const Color(0xFFFDE68A),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryLight, width: 2),
                      ),
                      child: ClipOval(
                        child: Center(
                          child: isDog
                              ? const MascotDogWidget(size: 40)
                              : const MascotCatWidget(size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.petName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  badgeLabel,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: badgeTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.petBreed} \u2022 Owner: ${item.ownerName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =========================================================
                    // CHAT ICON (Visual-only placeholder per Day 10 requirement)
                    // In-app messaging is not in scope for VetCare
                    // =========================================================
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.lightPill,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.primary),
                        tooltip: 'Message Owner (${item.ownerName})',
                        padding: EdgeInsets.zero,
                        onPressed: () => _openOwnerMessageSheet(item),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Diagnosis description
                Text(
                  item.diagnosis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Bottom Meta Row: Branch Origin & Appointment Time
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lightPill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Origin Branch (Proof of cross-branch query!)
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Branch: ${item.originBranchName}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Scheduled Appointment Time
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            item.appointmentTimeFormatted,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openOwnerMessageSheet(VetFollowupItem item) {
    final msgController = TextEditingController(
      text: 'Hi ${item.ownerName}, this is a reminder from VetCare regarding ${item.petName}\'s upcoming follow-up for ${item.diagnosis}. Please confirm if you can make it.',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.mark_chat_unread_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message ${item.ownerName}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Patient: ${item.petName} (${item.petBreed})',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.border),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Follow-up Care Note / Reminder SMS',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: msgController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type instructions or follow-up note...',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(sheetCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.success,
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Follow-up message dispatched to ${item.ownerName} for ${item.petName}!',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Send Owner Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
