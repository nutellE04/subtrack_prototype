import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../models/subscription.dart';
import 'subscription_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Default to Month view
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final subs = Provider.of<SubscriptionProvider>(context).subscriptions;

    // Map subscriptions to events
    List<Subscription> _getEventsForDay(DateTime day) {
      return subs.where((sub) {
        final nextDate = sub.nextPaymentDate;
        return nextDate.year == day.year && 
               nextDate.month == day.month && 
               nextDate.day == day.day;
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          // CUSTOM FORMAT SELECTOR
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFormatButton(CalendarFormat.month, 'Month'),
                _buildFormatButton(CalendarFormat.twoWeeks, '2 Weeks'),
                _buildFormatButton(CalendarFormat.week, 'Week'),
              ],
            ),
          ),
          
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            
            // HIDE the confusing default button
            headerStyle: const HeaderStyle(
              formatButtonVisible: false, 
              titleCentered: true,
            ),

            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            
            // Handle format changes
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          Expanded(
            child: _selectedDay == null 
              ? const Center(child: Text('Select a day to view payments'))
              : ListView(
                  children: _getEventsForDay(_selectedDay!).map((sub) => ListTile(
                    leading: const Icon(Icons.payment),
                    title: Text(sub.name),
                    trailing: Text('\$${sub.cost.toStringAsFixed(2)}'),
                    // FIX: Added onTap navigation
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => SubscriptionDetailScreen(subscription: sub)
                        )
                      );
                    },
                  )).toList(),
                ),
          )
        ],
      ),
    );
  }

  // Helper widget for the custom buttons
  Widget _buildFormatButton(CalendarFormat format, String label) {
    final isSelected = _calendarFormat == format;
    return InkWell(
      onTap: () {
        setState(() {
          _calendarFormat = format;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}