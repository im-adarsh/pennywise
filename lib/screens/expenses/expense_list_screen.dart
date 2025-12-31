import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:pennywise/providers/expense_provider.dart';
import 'package:pennywise/providers/member_provider.dart';
import 'package:pennywise/models/household_member.dart';
import 'package:pennywise/screens/expenses/add_expense_screen.dart';
import 'package:pennywise/widgets/category_icon.dart';
import 'package:getwidget/getwidget.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final membersAsync = ref.watch(membersProvider);

    return expensesAsync.when(
      data: (expenses) {
        if (expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No expenses yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first expense',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          );
        }

        return membersAsync.when(
          data: (members) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                HouseholdMember? member;
                if (expense.memberId != null && members.isNotEmpty) {
                  try {
                    member = members.firstWhere(
                      (m) => m.id == expense.memberId,
                    );
                  } catch (e) {
                    member = null;
                  }
                }

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: GFCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        content: ListTile(
                          leading: CategoryIcon.getIcon(expense.category),
                          title: Text(expense.description),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat('MMM dd, yyyy')
                                  .format(expense.date)),
                              if (member != null)
                                Text(
                                  'By ${member.name}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                          trailing: Text(
                            '\$${expense.amount.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddExpenseScreen(expense: expense),
                              ),
                            );
                          },
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Expense'),
                                content: const Text(
                                    'Are you sure you want to delete this expense?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ref
                                          .read(expenseServiceProvider)
                                          .deleteExpense(expense.id);
                                      ref.invalidate(expensesProvider);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
