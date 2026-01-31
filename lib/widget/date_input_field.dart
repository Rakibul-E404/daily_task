import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class DateOfBirthField extends StatefulWidget {
  final ValueChanged<String>? onDateSelected;

  const DateOfBirthField({super.key, this.onDateSelected});

  @override
  State<DateOfBirthField> createState() => _DateOfBirthFieldState();
}

class _DateOfBirthFieldState extends State<DateOfBirthField> {
  String? _selectedDate; // null = show placeholder

  Future<void> _showDatePicker() async {
    final DateTime now = DateTime.now();
    final DateTime minDate = DateTime(1900);
    final DateTime maxDate = now;
    final DateTime initialDate = _selectedDate != null
        ? _parseFormattedDate(_selectedDate!)
        : now.subtract(const Duration(days: 365 * 18));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(maxDate) ? maxDate : initialDate,
      firstDate: minDate,
      lastDate: maxDate,
      helpText: 'SELECT DATE OF BIRTH',
      cancelText: 'CANCEL',
      confirmText: 'SELECT',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = '${picked.month.toString().padLeft(2, '0')} - '
          '${picked.day.toString().padLeft(2, '0')} - '
          '${picked.year}';
      setState(() {
        _selectedDate = formatted;
      });
      widget.onDateSelected?.call(formatted);
    }
  }

  DateTime _parseFormattedDate(String formatted) {
    try {
      final parts = formatted.split(' - ');
      if (parts.length == 3) {
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      // fallback
    }
    return DateTime.now().subtract(const Duration(days: 365 * 18));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true, // 🔒 No keyboard, no manual input
      onTap: _showDatePicker,
      controller: TextEditingController(
        text: _selectedDate ?? '', // empty when null
      ),
      decoration: InputDecoration(
        hintText: _selectedDate == null ? 'Date of Birth' : '',
        hintStyle:  TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          color: AppColors.black,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.grey, width: 2.0),
        ),
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_outlined, color: Colors.grey[700]),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: VerticalDivider(
                    color: AppColors.grey,
                    width: 1,
                    thickness: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        // suffixIcon: IconButton(
        //   icon: Icon(Icons.calendar_month, color: Colors.grey[700]),
        //   onPressed: _showDatePicker,
        // ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: AppColors.grey),
        ),
      ),
    );
  }
}