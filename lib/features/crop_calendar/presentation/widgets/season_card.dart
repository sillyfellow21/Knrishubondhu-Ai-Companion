import 'package:flutter/material.dart';
import '../../domain/entities/season_calendar.dart';

/// Season Card Widget with Year Comparison
class SeasonCard extends StatelessWidget {
  final SeasonCalendar season;
  final VoidCallback onTap;
  
  const SeasonCard({
    super.key,
    required this.season,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    // Calculate production comparison
    final lastYear = _parseProduction(season.lastYearProduction);
    final thisYear = _parseProduction(season.thisYearProduction);
    final increase = thisYear - lastYear;
    final percentageChange = lastYear > 0 ? (increase / lastYear) * 100 : 0;
    final isIncrease = increase >= 0;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Season header
              Row(
                children: [
                  // Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        season.icon,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Season name and months
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          season.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          season.months,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              
              // Production comparison
              const Text(
                'উৎপাদন তুলনা',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Last year vs this year
              Row(
                children: [
                  Expanded(
                    child: _buildProductionColumn(
                      context,
                      'গত বছর',
                      season.lastYearProduction,
                      Colors.grey.shade600,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Comparison indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isIncrease 
                          ? Colors.green.withAlpha((0.1 * 255).toInt())
                          : Colors.red.withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isIncrease ? Icons.trending_up : Icons.trending_down,
                          color: isIncrease ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${percentageChange.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isIncrease ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: _buildProductionColumn(
                      context,
                      'এই বছর',
                      season.thisYearProduction,
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Crops count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha((0.1 * 255).toInt()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.agriculture,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${season.crops.length}টি ফসল',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProductionColumn(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  double _parseProduction(String production) {
    try {
      // Remove "কেজি" and parse the number
      final numStr = production.replaceAll('কেজি', '').trim();
      return double.parse(numStr);
    } catch (e) {
      return 0;
    }
  }
}
