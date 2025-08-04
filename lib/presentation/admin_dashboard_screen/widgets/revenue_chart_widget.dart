import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class RevenueChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> revenueData;

  const RevenueChartWidget({
    Key? key,
    required this.revenueData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (revenueData.isEmpty) {
      return Container(
        height: 200.sp,
        child: Center(
          child: Text(
            'No revenue data available',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 200.sp,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _getMaxRevenue() / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40.sp,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${value.toInt()}',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30.sp,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < revenueData.length) {
                    final date =
                        DateTime.parse(revenueData[value.toInt()]['date']);
                    return Text(
                      DateFormat('MMM dd').format(date),
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
              left: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          minX: 0,
          maxX: (revenueData.length - 1).toDouble(),
          minY: 0,
          maxY: _getMaxRevenue(),
          lineBarsData: [
            LineChartBarData(
              spots: _getSpots(),
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Colors.deepOrange, Colors.orange],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.deepOrange,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.deepOrange.withAlpha(77),
                    Colors.orange.withAlpha(26),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.black87,
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final date =
                      DateTime.parse(revenueData[barSpot.x.toInt()]['date']);
                  final revenue = barSpot.y;

                  return LineTooltipItem(
                    '${DateFormat('MMM dd').format(date)}\n\$${revenue.toStringAsFixed(2)}',
                    GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return revenueData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final revenue = (data['revenue'] as num?)?.toDouble() ?? 0.0;
      return FlSpot(index.toDouble(), revenue);
    }).toList();
  }

  double _getMaxRevenue() {
    if (revenueData.isEmpty) return 100;

    final maxRevenue = revenueData
        .map((data) => (data['revenue'] as num?)?.toDouble() ?? 0.0)
        .reduce((a, b) => a > b ? a : b);

    // Add 20% padding to the max value
    return maxRevenue * 1.2;
  }
}
