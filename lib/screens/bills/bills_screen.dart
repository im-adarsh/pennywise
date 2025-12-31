import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pennywise/services/bill_service.dart';
import 'package:pennywise/screens/bills/add_bill_screen.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bill Reminders')),
      body: Consumer<BillService>(
        builder: (context, billService, _) {
          if (billService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final bills = billService.bills;

          if (bills.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bills yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a bill reminder to track recurring payments',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.calendar_today,
                    color: bill.isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  title: Text(bill.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Due on day ${bill.dayOfMonth} of each month'),
                      if (bill.description != null) Text(bill.description!),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${bill.amount.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (!bill.isActive)
                        Text(
                          'Inactive',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddBillScreen(bill: bill),
                      ),
                    );
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Bill'),
                        content: const Text(
                            'Are you sure you want to delete this bill?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              billService.deleteBill(bill.id);
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
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddBillScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Bill'),
      ),
    );
  }
}
