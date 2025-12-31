import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pennywise/services/expense_service.dart';
import 'package:pennywise/services/member_service.dart';
import 'package:pennywise/services/export_service.dart';
import 'package:pennywise/widgets/category_icon.dart';

class MonthlySummaryScreen extends StatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
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
            child: Consumer2<ExpenseService, MemberService>(
              builder: (context, expenseService, memberService, _) {
                final monthExpenses =
                    expenseService.getExpensesByMonth(_selectedMonth);
                final total = expenseService.getTotalByMonth(_selectedMonth);
                final categoryTotals =
                    expenseService.getCategoryTotalsByMonth(_selectedMonth);
                final memberTotals =
                    _getMemberTotals(monthExpenses, memberService.members);

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
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
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
                    Card(
                      color: Theme.of(context).colorScheme.primary,
                      child: Padding(
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
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CategoryIcon.getIcon(entry.key),
                            title: Text(entry.key),
                            subtitle: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${entry.value.toStringAsFixed(2)}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
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
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                entry.key[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(entry.key),
                            subtitle: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${entry.value.toStringAsFixed(2)}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
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
        final member = members.firstWhere(
          (m) => m.id == expense.memberId,
          orElse: () => members.first,
        );
        totals[member.name] = (totals[member.name] ?? 0.0) + expense.amount;
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
    final expenseService = Provider.of<ExpenseService>(context, listen: false);
    final exportService = ExportService();

    try {
      if (format == 'csv') {
        await exportService.exportToCSV(expenseService.expenses);
      } else {
        await exportService.exportToPDF(
            expenseService.expenses, _selectedMonth);
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
