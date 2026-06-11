import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';

class AluDateTimeFormatter {
  AluDateTimeFormatter._();

  static final _displayDate = DateFormat('MMM d, yyyy');
  static final _displayTime = DateFormat('hh:mm a');

  static String formatDate(DateTime date) => _displayDate.format(date);

  static DateTime? parseDate(String value) {
    if (value.isEmpty) return null;
    return _displayDate.parseLoose(value);
  }

  static TimeOfDay? parseTime(String value) {
    if (value.isEmpty) return null;
    try {
      final dt = _displayTime.parse(value);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      return null;
    }
  }

  static String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return _displayTime.format(dt);
  }

  static String formatRange(String time, String endTime) {
    if (time.isEmpty) return endTime;
    if (endTime.isEmpty) return time;
    return '$time - $endTime';
  }

  static String shortDate(String date) {
    final parts = date.split(' ');
    if (parts.length >= 2) return '${parts[0]} ${parts[1]}';
    return date;
  }

  static String compactLabel({
    required String date,
    String time = '',
    String deadline = '',
  }) {
    if (deadline.isNotEmpty) return 'Deadline: $deadline';
    if (time.isNotEmpty) return '$date • $time';
    return date;
  }
}

enum AluDateTimeDisplayStyle { compact, inline, detail }

class AluDateTimeDisplay extends StatelessWidget {
  const AluDateTimeDisplay({
    super.key,
    required this.date,
    this.time = '',
    this.endTime = '',
    this.deadline = '',
    this.style = AluDateTimeDisplayStyle.compact,
    this.icon = Icons.calendar_today_outlined,
    this.alignEnd = false,
  });

  final String date;
  final String time;
  final String endTime;
  final String deadline;
  final AluDateTimeDisplayStyle style;
  final IconData icon;
  final bool alignEnd;

  bool get _isDeadline => deadline.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case AluDateTimeDisplayStyle.detail:
        return _DetailLayout(
          icon: _isDeadline ? Icons.schedule_rounded : Icons.calendar_month_rounded,
          title: _isDeadline ? 'Application Deadline' : date,
          subtitle: _isDeadline
              ? deadline
              : AluDateTimeFormatter.formatRange(time, endTime),
        );
      case AluDateTimeDisplayStyle.inline:
        return _InlineLayout(
          icon: icon,
          label: AluDateTimeFormatter.compactLabel(
            date: date,
            time: time,
            deadline: deadline,
          ),
          alignEnd: alignEnd,
        );
      case AluDateTimeDisplayStyle.compact:
        return _InlineLayout(
          icon: icon,
          label: AluDateTimeFormatter.compactLabel(
            date: date,
            time: time,
            deadline: deadline,
          ),
          alignEnd: alignEnd,
          fontSize: 12,
          iconSize: 14,
        );
    }
  }
}

class AluDateTimePicker extends StatelessWidget {
  const AluDateTimePicker({
    super.key,
    required this.dateLabel,
    required this.selectedDate,
    required this.onDateChanged,
    this.showTime = true,
    this.selectedTime,
    this.onTimeChanged,
    this.errorText,
  });

  final String dateLabel;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final bool showTime;
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final String? errorText;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onDateChanged(picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? const TimeOfDay(hour: 14, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onTimeChanged?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate != null
        ? AluDateTimeFormatter.formatDate(selectedDate!)
        : null;
    final timeText =
        selectedTime != null ? AluDateTimeFormatter.formatTime(selectedTime!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _PickerTile(
                label: dateLabel,
                value: dateText,
                hint: 'Select date',
                icon: Icons.calendar_today_outlined,
                hasError: errorText != null,
                onTap: () => _pickDate(context),
              ),
            ),
            if (showTime) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _PickerTile(
                  label: 'Time',
                  value: timeText,
                  hint: 'Select time',
                  icon: Icons.access_time_outlined,
                  onTap: () => _pickTime(context),
                ),
              ),
            ],
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.hasError = false,
  });

  final String label;
  final String? value;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          errorBorder: hasError
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error),
                )
              : null,
          focusedErrorBorder: hasError
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error),
                )
              : null,
        ),
        child: Text(
          hasValue ? value! : hint,
          style: TextStyle(
            color: hasValue ? AppColors.textPrimary : AppColors.textMuted,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _InlineLayout extends StatelessWidget {
  const _InlineLayout({
    required this.icon,
    required this.label,
    this.alignEnd = false,
    this.fontSize = 11,
    this.iconSize = 12,
  });

  final IconData icon;
  final String label;
  final bool alignEnd;
  final double fontSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: alignEnd ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Icon(icon, size: iconSize, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            style: TextStyle(
              color: alignEnd ? AppColors.textMuted : AppColors.textSecondary,
              fontSize: fontSize,
            ),
          ),
        ),
      ],
    );

    return alignEnd ? row : row;
  }
}

class _DetailLayout extends StatelessWidget {
  const _DetailLayout({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.gold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
