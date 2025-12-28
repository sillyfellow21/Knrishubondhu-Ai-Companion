import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/loan.dart';

class LoanCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const LoanCard(
      {super.key, required this.loan, required this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy');
    final progress = loan.amount > 0 ? loan.paidAmount / loan.amount : 0.0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(loan.lenderName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold))),
                  if (onDelete != null)
                    IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(context),
                        tooltip: 'মুছে ফেলুন'),
                ],
              ),
              const SizedBox(height: 8),
              Text(loan.purpose,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildAmountColumn(
                          'মোট ঋণ', loan.amount, Colors.blue)),
                  Expanded(
                      child: _buildAmountColumn(
                          'পরিশোধিত', loan.paidAmount, Colors.green)),
                  Expanded(
                      child: _buildAmountColumn(
                          'বাকি', loan.remainingAmount, Colors.orange)),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      loan.isPaid ? Colors.green : Colors.blue)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('তারিখ: ${dateFormat.format(loan.loanDate)}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: _getStatusColor(loan.status)
                            .withAlpha((0.2 * 255).toInt()),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(_getStatusText(loan.status),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(loan.status))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountColumn(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 4),
        Text('৳${amount.toStringAsFixed(0)}',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'পরিশোধিত';
      case 'partial':
        return 'আংশিক';
      default:
        return 'বাকি';
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('নিশ্চিত করুন'),
                content:
                    Text('আপনি কি "${loan.lenderName}" এর ঋণ মুছে ফেলতে চান?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('বাতিল')),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete?.call();
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('মুছে ফেলুন'))
                ]));
  }
}
