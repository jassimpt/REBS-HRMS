import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../../../core/helpers/company_clock.dart';

class LeaveDateField extends StatelessWidget {
  const LeaveDateField({
    required this.label,
    required this.value,
    required this.today,
    required this.firstDate,
    required this.onSelected,
    this.error,
    this.enabled = true,
    super.key,
  });

  final String label;
  final String? value;
  final DateTime today;
  final DateTime firstDate;
  final ValueChanged<DateTime> onSelected;
  final String? error;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      child: InkWell(
        onTap: !enabled
            ? null
            : () async {
                final selected = value == null
                    ? firstDate
                    : CompanyClock.parseCalendarDate(value!);
                final date = await showDatePicker(
                  context: context,
                  initialDate: selected.isBefore(firstDate)
                      ? firstDate
                      : selected,
                  currentDate: today,
                  firstDate: firstDate,
                  lastDate: DateTime.utc(today.year + 10, 12, 31),
                );
                if (date != null) onSelected(date);
              },
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            enabled: enabled,
            errorText: error,
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
          ),
          child: Text(
            value == null
                ? TextConstants.selectDate
                : CompanyClock.calendarDate(value!),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
