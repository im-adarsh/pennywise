import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:getwidget/getwidget.dart';
import 'package:pennywise/providers/auth_provider.dart';
import 'package:pennywise/providers/expense_provider.dart';
import 'package:pennywise/providers/bill_provider.dart';
import 'package:pennywise/providers/subscription_provider.dart';
import 'package:pennywise/screens/expenses/add_expense_screen.dart';
import 'package:pennywise/screens/expenses/expense_list_screen.dart';
import 'package:pennywise/screens/bills/bills_screen.dart';
import 'package:pennywise/screens/members/members_screen.dart';
import 'package:pennywise/screens/summary/monthly_summary_screen.dart';
import 'package:pennywise/widgets/category_icon.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Expense Book'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.signOut();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          ExpenseListScreen(),
          BillsScreen(),
          MembersScreen(),
          MonthlySummaryScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Expenses'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Bills'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
          BottomNavigationBarItem(
              icon: Icon(Icons.summarize), label: 'Summary'),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            )
          : null,
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final billsAsync = ref.watch(billsProvider);
    final subscriptionState = ref.watch(subscriptionServiceProvider);
    final expenseService = ref.watch(expenseServiceProvider);

    return expensesAsync.when(
      data: (expenses) => billsAsync.when(
        data: (bills) {
          final now = DateTime.now();
          final thisMonthExpenses =
              expenseService.getExpensesByMonth(expenses, now);
          final totalThisMonth = expenseService.getTotalByMonth(expenses, now);
          final categoryTotals =
              expenseService.getCategoryTotalsByMonth(expenses, now);
          final billService = ref.watch(billServiceProvider);
          final upcomingBills = billService.getUpcomingBills(bills);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(expensesProvider);
              ref.invalidate(billsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  // Monthly Total Card
                  GFCard(
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This Month',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${totalThisMonth.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${thisMonthExpenses.length} expenses',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Breakdown
                  if (categoryTotals.isNotEmpty) ...[
                    Text(
                      'Category Breakdown',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...categoryTotals.entries.map((entry) {
                      final percentage = (entry.value / totalThisMonth * 100);
                      return GFCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        content: ListTile(
                          leading: CategoryIcon.getIcon(entry.key),
                          title: Text(entry.key),
                          subtitle: GFProgressBar(
                            percentage: percentage,
                            backgroundColor: Colors.grey[200]!,
                            progressBarColor:
                                Theme.of(context).colorScheme.primary,
                            lineHeight: 8,
                          ),
                          trailing: Text(
                            '\$${entry.value.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  // Upcoming Bills
                  if (upcomingBills.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Bills',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to bills tab
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...upcomingBills.take(3).map((bill) {
                      return GFCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        content: ListTile(
                          leading: Icon(
                            Icons.calendar_today,
                            color: bill.isActive
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          ),
                          title: Text(bill.name),
                          subtitle: Text('Due on day ${bill.dayOfMonth}'),
                          trailing: Text(
                            '\$${bill.amount.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      );
                    }),
                  ],

                  // Ad Banner (if not subscribed)
                  if (!subscriptionState.isSubscribed) ...[
                    const SizedBox(height: 16),
                    GFCard(
                      color: Colors.orange[50],
                      content: Column(
                        children: [
                          Text(
                            'Remove Ads',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Subscribe for \$0.55/month to enjoy an ad-free experience',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          GFButton(
                            onPressed: subscriptionState.isLoading
                                ? null
                                : () {
                                    ref
                                        .read(subscriptionServiceProvider
                                            .notifier)
                                        .purchaseSubscription();
                                  },
                            text: 'Subscribe',
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
