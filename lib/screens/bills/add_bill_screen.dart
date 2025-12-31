import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:pennywise/services/bill_service.dart';
import 'package:pennywise/models/bill.dart';

class AddBillScreen extends StatefulWidget {
  final Bill? bill;

  const AddBillScreen({super.key, this.bill});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _selectedDay = 1;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.bill != null) {
      _nameController.text = widget.bill!.name;
      _amountController.text = widget.bill!.amount.toString();
      _descriptionController.text = widget.bill!.description ?? '';
      _selectedDay = widget.bill!.dayOfMonth;
      _isActive = widget.bill!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final billService = Provider.of<BillService>(context, listen: false);
    final userId = billService.userId;
    if (userId == null) return;

    final bill = Bill(
      id: widget.bill?.id ?? const Uuid().v4(),
      userId: userId,
      name: _nameController.text,
      amount: double.parse(_amountController.text),
      dayOfMonth: _selectedDay,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      isActive: _isActive,
      createdAt: widget.bill?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.bill != null) {
      await billService.updateBill(bill);
    } else {
      await billService.addBill(bill);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bill == null ? 'Add Bill' : 'Edit Bill'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Bill Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bill name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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

              // Day of Month Selection
              DropdownButtonFormField<int>(
                value: _selectedDay,
                decoration:
                    const InputDecoration(labelText: 'Due Day of Month'),
                items: List.generate(31, (index) => index + 1).map((day) {
                  return DropdownMenuItem(
                    value: day,
                    child: Text('Day $day'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedDay = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Active Toggle
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Bill reminder is active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value);
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveBill,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.bill == null ? 'Add Bill' : 'Update Bill'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
