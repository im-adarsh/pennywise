import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:pennywise/services/member_service.dart';
import 'package:pennywise/models/household_member.dart';

class AddMemberScreen extends StatefulWidget {
  final HouseholdMember? member;

  const AddMemberScreen({super.key, this.member});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _nameController.text = widget.member!.name;
      _emailController.text = widget.member!.email ?? '';
      _phoneController.text = widget.member!.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final memberService = Provider.of<MemberService>(context, listen: false);
    final userId = memberService.userId;
    if (userId == null) return;

    final member = HouseholdMember(
      id: widget.member?.id ?? const Uuid().v4(),
      userId: userId,
      name: _nameController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      createdAt: widget.member?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.member != null) {
      await memberService.updateMember(member);
    } else {
      await memberService.addMember(member);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.member == null ? 'Add Member' : 'Edit Member'),
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
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration:
                    const InputDecoration(labelText: 'Email (Optional)'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration:
                    const InputDecoration(labelText: 'Phone (Optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveMember,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.member == null ? 'Add Member' : 'Update Member'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
