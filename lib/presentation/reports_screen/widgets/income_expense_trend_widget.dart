import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class IncomeExpenseTrendWidget extends StatefulWidget {
  final List<Map<String, dynamic>> trendData;
  final String timeframe;

  const IncomeExpenseTrendWidget({
    super.key,
    required this.trendData,
    required this.timeframe,
  });

  @override
  State<IncomeExpenseTrendWidget> createState() =>
      _IncomeExpenseTrendWidgetState();
}

class _IncomeExpenseTrendWidgetState extends State<IncomeExpenseTrendWidget> {
  bool showIncome = true;
  bool showExpense = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Income vs Expense Trend',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.timeframe,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildLegendRow(theme),
          SizedBox(height: 2.h),
          SizedBox(
            height: 25.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.dividerColor,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: theme.dividerColor,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: _buildBottomTitles,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1000,
                      getTitlesWidget: _buildLeftTitles,
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: theme.dividerColor),
                ),
                minX: 0,
                maxX: (widget.trendData.length - 1).toDouble(),
                minY: 0,
                maxY: _getMaxY(),
                lineBarsData: _buildLineBarsData(theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(ThemeData theme) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => showIncome = !showIncome),
          child: Row(
            children: [
              Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: showIncome
                      ? AppTheme.getSuccessColor(
                          theme.brightness == Brightness.light)
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                'Income',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: showIncome
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 6.w),
        GestureDetector(
          onTap: () => setState(() => showExpense = !showExpense),
          child: Row(
            children: [
              Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: showExpense ? theme.colorScheme.error : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                'Expense',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: showExpense
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _getMaxY() {
    double maxIncome = 0;
    double maxExpense = 0;

    for (final data in widget.trendData) {
      final income = data['income'] as double;
      final expense = data['expense'] as double;
      if (income > maxIncome) maxIncome = income;
      if (expense > maxExpense) maxExpense = expense;
    }

    return (maxIncome > maxExpense ? maxIncome : maxExpense) * 1.2;
  }

  List<LineChartBarData> _buildLineBarsData(ThemeData theme) {
    final List<LineChartBarData> bars = [];

    if (showIncome) {
      bars.add(
        LineChartBarData(
          spots: widget.trendData.asMap().entries.map((entry) {
            return FlSpot(
              entry.key.toDouble(),
              entry.value['income'] as double,
            );
          }).toList(),
          isCurved: true,
          color: AppTheme.getSuccessColor(theme.brightness == Brightness.light),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color:
                AppTheme.getSuccessColor(theme.brightness == Brightness.light)
                    .withAlpha(26),
          ),
        ),
      );
    }

    if (showExpense) {
      bars.add(
        LineChartBarData(
          spots: widget.trendData.asMap().entries.map((entry) {
            return FlSpot(
              entry.key.toDouble(),
              entry.value['expense'] as double,
            );
          }).toList(),
          isCurved: true,
          color: theme.colorScheme.error,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: theme.colorScheme.error.withAlpha(26),
          ),
        ),
      );
    }

    return bars;
  }

  Widget _buildBottomTitles(double value, TitleMeta meta) {
    final theme = Theme.of(context);
    if (value.toInt() >= widget.trendData.length) {
      return Container();
    }

    final data = widget.trendData[value.toInt()];
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        data['label'] as String,
        style: theme.textTheme.bodySmall,
      ),
    );
  }

  Widget _buildLeftTitles(double value, TitleMeta meta) {
    final theme = Theme.of(context);
    return Text(
      '\$${(value / 1000).toStringAsFixed(0)}k',
      style: theme.textTheme.bodySmall,
      textAlign: TextAlign.left,
    );
  }
}
