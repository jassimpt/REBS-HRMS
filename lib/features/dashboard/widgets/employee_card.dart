import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';
import '../models/employee_model.dart';

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({required this.employee, super.key});

  final EmployeeModel employee;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            employee.department,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            employee.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            employee.designation,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              Text(
                TextConstants.employeeId(employee.id),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              Text(
                employee.office.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
