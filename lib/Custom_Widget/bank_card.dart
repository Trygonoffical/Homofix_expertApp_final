import 'package:flutter/material.dart';

class BankAccountCard extends StatelessWidget {
  final String name;
  final String ifscCode;
  final String accountNumber;
  final String bankName;

  BankAccountCard({
    required this.name,
    required this.ifscCode,
    required this.accountNumber,
    required this.bankName,
  });

  @override
  Widget build(BuildContext context) {
    // Define different colors for the container
    List<Color> colors = [
      Colors.blue.withOpacity(0.1),
      Colors.green.withOpacity(0.1),
      Colors.orange.withOpacity(0.1),
      Colors.purple.withOpacity(0.1)
    ];
    // Choose a random color index
    int colorIndex = DateTime.now().millisecondsSinceEpoch % colors.length;

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: colors[colorIndex],
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: $name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'IFSC Code: $ifscCode',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Account Number: $accountNumber',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Bank Name: $bankName',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
