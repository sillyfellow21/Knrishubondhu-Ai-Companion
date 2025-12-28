import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/loan.dart';

class LoanChartWidget extends StatelessWidget {
  final List<Loan> loans;
  
  const LoanChartWidget({super.key, required this.loans});
  
  @override
  Widget build(BuildContext context) {
    if (loans.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text('কোনো ঋণ নেই')));
    }
    
    final chartData = _prepareChartData();
    
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: chartData['maxY'] as double,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < loans.length) {
                return Padding(padding: const EdgeInsets.only(top: 8), child: Text(loans[index].lenderName.length > 8 ? '${loans[index].lenderName.substring(0, 8)}...' : loans[index].lenderName, style: const TextStyle(fontSize: 10)));
              }
              return const Text('');
            })),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barGroups: chartData['barGroups'] as List<BarChartGroupData>,
        ),
      ),
    );
  }
  
  Map<String, dynamic> _prepareChartData() {
    double maxY = 0;
    final barGroups = <BarChartGroupData>[];
    
    for (int i = 0; i < loans.length; i++) {
      final loan = loans[i];
      if (loan.amount > maxY) maxY = loan.amount;
      
      barGroups.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: loan.amount, color: Colors.blue.shade300, width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
        BarChartRodData(toY: loan.paidAmount, color: Colors.green, width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
      ]));
    }
    
    return {'maxY': maxY * 1.2, 'barGroups': barGroups};
  }
}
