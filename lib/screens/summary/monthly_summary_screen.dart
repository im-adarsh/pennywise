import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:getwidget/getwidget.dart';
import 'package:pennywise/providers/expense_provider.dart';
import 'package:pennywise/providers/member_provider.dart';
import 'package:pennywise/services/export_service.dart';
import 'package:pennywise/widgets/category_icon.dart';

class MonthlySummaryScreen extends ConsumerStatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  ConsumerState<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends ConsumerState<MonthlySummaryScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);
    final membersAsync = ref.watch(membersProvider);
    final expenseService = ref.watch(expenseServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _showExportDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Selector
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _selectedMonth =
                        DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                  });
                },
              ),
              title: Text(
                DateFormat('MMMM yyyy').format(_selectedMonth),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  final now = DateTime.now();
                  if (_selectedMonth.year < now.year ||
                      (_selectedMonth.year == now.year &&
                          _selectedMonth.month < now.month)) {
                    setState(() {
                      _selectedMonth = DateTime(
                          _selectedMonth.year, _selectedMonth.month + 1);
                    });
                  }
                },
              ),
            ),
          ),

          // Summary Content
          Expanded(
            child: expensesAsync.when(
              data: (expenses) => membersAsync.when(
                data: (members) {
                  final monthExpenses =
                      expenseService.getExpensesByMonth(expenses, _selectedMonth);
                  final total = expenseService.getTotalByMonth(expenses, _selectedMonth);
                  final categoryTotals =
                      expenseService.getCategoryTotalsByMonth(expenses, _selectedMonth);
                  final memberTotals = _getMemberTotals(monthExpenses, members);

                  if (monthExpenses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No expenses for this month',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Total Card
                      GFCard(
                        color: Theme.of(context).colorScheme.primary,
                        content: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                'Total Expenses',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${monthExpenses.length} expenses',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category Breakdown
                      if (categoryTotals.isNotEmpty) ...[
                        Text(
                          'By Category',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ...categoryTotals.entries.map((entry) {
                          final percentage = (entry.value / total * 100);
                          return GFCard(
                            margin: const EdgeInsets.only(bottom: 8),
                            content: ListTile(
                              leading: CategoryIcon.getIcon(entry.key),
                              title: Text(entry.key),
                              subtitle: GFProgressBar(
                                percentage: percentage,
                                backgroundColor: Colors.grey[200]!,
                                progressBarColor: Theme.of(context).colorScheme.primary,
                                lineHeight: 8,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${entry.value.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],

                      // Member Breakdown
                      if (memberTotals.isNotEmpty) ...[
                        Text(
                          'By Member',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ...memberTotals.entries.map((entry) {
                          final percentage = (entry.value / total * 100);
                          return GFCard(
                            margin: const EdgeInsets.only(bottom: 8),
                            content: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: Text(
                                  entry.key[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(entry.key),
                              subtitle: GFProgressBar(
                                percentage: percentage,
                                backgroundColor: Colors.grey[200]!,
                                progressBarColor: Theme.of(context).colorScheme.secondary,
                                lineHeight: 8,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${entry.value.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _getMemberTotals(List expenses, List members) {
    final Map<String, double> totals = {};
    for (var expense in expenses) {
      if (expense.memberId != null) {
        try {
          final member = members.firstWhere(
            (m) => m.id == expense.memberId,
          );
          totals[member.name] = (totals[member.name] ?? 0.0) + expense.amount;
        } catch (e) {
          totals['Unassigned'] = (totals['Unassigned'] ?? 0.0) + expense.amount;
        }
      } else {
        totals['Unassigned'] = (totals['Unassigned'] ?? 0.0) + expense.amount;
      }
    }
    return totals;
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData(context, 'csv');
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportData(context, 'pdf');
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, String format) async {
    final expensesAsync = ref.read(expensesProvider);
    final exportService = ExportService();

    try {
      final expenses = await expensesAsync.value ?? [];
      if (format == 'csv') {
        await exportService.exportToCSV(expenses);
      } else {
        await exportService.exportToPDF(expenses, _selectedMonth);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully as $format'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
