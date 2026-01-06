import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../services/auth_service.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final Subscription? subscription;
  const AddSubscriptionScreen({super.key, this.subscription});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late String _name;
  late double _cost;
  late String _billingCycle;
  late DateTime _startDate;
  late String _category;
  late bool _remindMe;

  @override
  void initState() {
    super.initState();
    final sub = widget.subscription;
    _name = sub?.name ?? '';
    _cost = sub?.cost ?? 0.0;
    _billingCycle = sub?.billingCycle ?? 'Monthly';
    _startDate = sub?.startDate ?? DateTime.now();
    _category = sub?.category ?? 'Entertainment';
    _remindMe = sub?.remindMe ?? false;
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);
    final userId = auth.currentUserId;

    if (userId == null) return;

    final newSub = Subscription(
      id: widget.subscription?.id ?? const Uuid().v4(),
      userId: userId,
      name: _name,
      cost: _cost,
      billingCycle: _billingCycle,
      startDate: _startDate,
      category: _category,
      remindMe: _remindMe,
    );

    try {
      if (widget.subscription == null) {
        await provider.addSubscription(newSub);
      } else {
        await provider.updateSubscription(newSub);
      }
      // Check mounted before popping
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // Check mounted before SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _delete() async {
    if (widget.subscription != null) {
      final provider = Provider.of<SubscriptionProvider>(context, listen: false);
      await provider.deleteSubscription(widget.subscription!.id);
      // Check mounted before popping
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subscription == null ? 'Add Subscription' : 'Edit Subscription'),
        actions: [
          if (widget.subscription != null)
            IconButton(icon: const Icon(Icons.delete), onPressed: _delete)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter a name' : null,
                onSaved: (v) => _name = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _cost == 0 ? '' : _cost.toString(),
                decoration: const InputDecoration(labelText: 'Cost', prefixText: '\$ ', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => double.tryParse(v!) == null ? 'Enter valid cost' : null,
                onSaved: (v) => _cost = double.parse(v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _billingCycle,
                decoration: const InputDecoration(labelText: 'Billing Cycle', border: OutlineInputBorder()),
                items: ['Monthly', 'Yearly'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _billingCycle = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: ['Entertainment', 'Utilities', 'Work', 'Other'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(_startDate.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2100), initialDate: _startDate);
                  if (picked != null) setState(() => _startDate = picked);
                },
              ),
              SwitchListTile(
                title: const Text('Remind me?'),
                value: _remindMe,
                onChanged: (v) => setState(() => _remindMe = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Save Subscription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}