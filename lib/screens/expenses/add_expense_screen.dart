import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:pennywise/providers/expense_provider.dart';
import 'package:pennywise/providers/member_provider.dart';
import 'package:pennywise/models/expense.dart';
import 'package:pennywise/widgets/category_icon.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Food';
  String? _selectedMemberId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _amountController.text = widget.expense!.amount.toString();
      _descriptionController.text = widget.expense!.description;
      _selectedCategory = widget.expense!.category;
      _selectedMemberId = widget.expense!.memberId;
      _selectedDate = widget.expense!.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final expenseService = ref.read(expenseServiceProvider);
    final userId = expenseService.userId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final expense = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      userId: userId,
      memberId: _selectedMemberId,
      category: _selectedCategory,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text,
      date: _selectedDate,
      createdAt: widget.expense?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.expense != null) {
      await expenseService.updateExpense(expense);
    } else {
      await expenseService.addExpense(expense);
    }

    ref.invalidate(expensesProvider);

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selection
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: CategoryIcon.getCategories().map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        CategoryIcon.getIcon(category),
                        const SizedBox(width: 12),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Selection
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Member Selection (Optional)
              membersAsync.when(
                data: (members) {
                  if (members.isEmpty) return const SizedBox.shrink();

                  return DropdownButtonFormField<String?>(
                    value: _selectedMemberId,
                    decoration: const InputDecoration(
                      labelText: 'Household Member (Optional)',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('None'),
                      ),
                      ...members.map((member) {
                        return DropdownMenuItem(
                          value: member.id,
                          child: Text(member.name),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedMemberId = value);
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveExpense,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.expense == null
                            ? 'Add Expense'
                            : 'Update Expense',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
