import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event.dart';
import '../providers/auth_provider.dart';
import '../providers/children_provider.dart';
import '../providers/events_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/child_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_tile.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventsMap = ref.watch(eventsMapProvider);
    final children = ref.watch(childrenProvider).valueOrNull ?? [];
    final selectedChild = ref.watch(selectedChildIdProvider);

    final selectedDayEvents = eventsMap[AppHelpers.startOfDay(_selectedDay)] ?? [];
    final filteredEvents = selectedChild != null
        ? selectedDayEvents.where((e) => e.childId == selectedChild).toList()
        : selectedDayEvents;

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addEvent),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Calendar',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  // Format toggle
                  _FormatToggle(
                    current: _format,
                    onChanged: (f) => setState(() => _format = f),
                  ),
                ],
              ),
            ),

            // Child filter chips
            if (children.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    // All
                    GestureDetector(
                      onTap: () =>
                          ref.read(selectedChildIdProvider.notifier).state = null,
                      child: AnimatedContainer(
                        duration: 200.ms,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedChild == null
                              ? AppColors.accent
                              : AppColors.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'All',
                          style: TextStyle(
                            color: selectedChild == null
                                ? Colors.white
                                : AppColors.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    ...children.map(
                      (c) => ChildAvatarChip(
                        child: c,
                        isSelected: selectedChild == c.id,
                        onTap: () {
                          ref.read(selectedChildIdProvider.notifier).state =
                              selectedChild == c.id ? null : c.id;
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Calendar
            TableCalendar<FamilyEvent>(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
              calendarFormat: _format,
              eventLoader: (day) {
                final key = AppHelpers.startOfDay(day);
                return eventsMap[key] ?? [];
              },
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              onFormatChanged: (f) => setState(() => _format = f),
              onPageChanged: (day) => _focusedDay = day,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                selectedDecoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.accentLight,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(
                  Icons.chevron_left_rounded,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ),

            const Divider(height: 1),

            // Events for selected day
            Expanded(
              child: filteredEvents.isEmpty
                  ? EmptyState(
                      emoji: '📅',
                      title: 'No events',
                      subtitle: 'Tap + to add an event for this day',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredEvents.length,
                      itemBuilder: (_, i) => EventTile(
                        event: filteredEvents[i],
                        index: i,
                        onTap: () => _showEventDetail(context, filteredEvents[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetail(BuildContext context, FamilyEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EventDetailSheet(event: event),
    );
  }
}

class _FormatToggle extends StatelessWidget {
  final CalendarFormat current;
  final ValueChanged<CalendarFormat> onChanged;

  const _FormatToggle({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : AppColors.lightCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _FormatButton(
            label: 'W',
            selected: current == CalendarFormat.week,
            onTap: () => onChanged(CalendarFormat.week),
          ),
          _FormatButton(
            label: 'M',
            selected: current == CalendarFormat.month,
            onTap: () => onChanged(CalendarFormat.month),
          ),
        ],
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FormatButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.lightTextSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _EventDetailSheet extends StatelessWidget {
  final FamilyEvent event;

  const _EventDetailSheet({required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppHelpers.hexToColor(event.type.colorHex);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(event.type.emoji,
                    style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      event.type.label,
                      style: TextStyle(color: color, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailRow(
            icon: Icons.schedule_rounded,
            label: AppHelpers.formatTime(event.startDate) +
                (event.endDate != null
                    ? ' – ${AppHelpers.formatTime(event.endDate!)}'
                    : ''),
          ),
          if (event.location != null && event.location!.isNotEmpty)
            _DetailRow(icon: Icons.place_outlined, label: event.location!),
          if (event.amount != null)
            _DetailRow(
                icon: Icons.payments_outlined,
                label: AppHelpers.formatAmount(event.amount!)),
          if (event.notes != null && event.notes!.isNotEmpty)
            _DetailRow(icon: Icons.notes_rounded, label: event.notes!),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

extension on Duration {
  Duration get ms => Duration(milliseconds: inMilliseconds);
}
