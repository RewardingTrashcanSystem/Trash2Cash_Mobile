// features/history/presentation/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash2cash/features/transactions/data/model/history_model.dart';
import 'package:trash2cash/features/transactions/presentation/provider/histrory_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<String> _filterOptions = ['All', 'QR Scan', 'Received', 'Sent'];
  String _selectedFilter = 'All';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HistoryProvider>(context, listen: false);
      provider.fetchHistory();
    });
    
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final provider = Provider.of<HistoryProvider>(context, listen: false);
      if (!provider.isLoading && provider.hasMore) {
        provider.loadMore();
      }
    }
  }

  String _getActionFromFilter(String filter) {
    switch (filter) {
      case 'QR Scan':
        return 'scan';
      case 'Received':
        return 'transfer_in';
      case 'Sent':
        return 'transfer_out';
      default:
        return 'all';
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),

          // Summary card (only show for All filter)
          if (historyProvider.summary != null && _selectedFilter == 'All')
            _buildSummaryCard(historyProvider.summary!),

          // History list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await historyProvider.refreshHistory();
              },
              child: _buildHistoryList(historyProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterOptions.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                  
                  final provider = Provider.of<HistoryProvider>(context, listen: false);
                  final action = _getActionFromFilter(filter);
                  provider.fetchHistory(action: action);
                },
                backgroundColor: Colors.grey.shade200,
                selectedColor: Colors.green.shade600,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
                checkmarkColor: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total', summary['total_transactions']?.toString() ?? '0'),
          _buildSummaryItem('Received', '+${summary['total_points_received']?.toString() ?? '0'}'),
          _buildSummaryItem('Sent', '-${summary['total_points_sent']?.toString() ?? '0'}'),
          _buildSummaryItem('Net', '${summary['net_points']?.toString() ?? '0'}'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    bool isNegative = value.startsWith('-');
    bool isPositive = value.startsWith('+');
    
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isNegative ? Colors.red : (isPositive ? Colors.green : Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(HistoryProvider provider) {
    // Filter transactions based on selected filter
    List<HistoryModel> filteredTransactions = provider.history;
    
    if (_selectedFilter != 'All') {
      final actionFilter = _getActionFromFilter(_selectedFilter);
      filteredTransactions = provider.history
          .where((transaction) => transaction.action == actionFilter)
          .toList();
    }

    if (provider.isLoading && provider.history.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (filteredTransactions.isEmpty && !provider.isLoading) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: filteredTransactions.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredTransactions.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: provider.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('No more transactions'),
            ),
          );
        }

        final transaction = filteredTransactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }

  Widget _buildEmptyState() {
    String emptyMessage = '';
    IconData emptyIcon = Icons.history;
    
    switch (_selectedFilter) {
      case 'QR Scan':
        emptyMessage = 'No QR scan transactions yet\nScan QR codes to earn points';
        emptyIcon = Icons.qr_code_scanner;
        break;
      case 'Received':
        emptyMessage = 'No points received yet\nOthers can send you points';
        emptyIcon = Icons.download;
        break;
      case 'Sent':
        emptyMessage = 'No points sent yet\nTransfer points to other users';
        emptyIcon = Icons.upload;
        break;
      default:
        emptyMessage = 'No transactions yet\nScan QR codes or transfer points';
        emptyIcon = Icons.history;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            emptyIcon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyStateTitle(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),
          // Show action buttons for empty states
          if (_selectedFilter != 'All')
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFilter = 'All';
                });
                final provider = Provider.of<HistoryProvider>(context, listen: false);
                provider.fetchHistory();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('View All Transactions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  String _getEmptyStateTitle() {
    switch (_selectedFilter) {
      case 'QR Scan':
        return 'No Scan History';
      case 'Received':
        return 'No Received Points';
      case 'Sent':
        return 'No Sent Points';
      default:
        return 'No Transactions';
    }
  }

  Widget _buildTransactionItem(HistoryModel transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: transaction.colorValue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            transaction.iconData,
            color: transaction.colorValue,
          ),
        ),
        title: Text(
          _getActionTitle(transaction.action),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  '${transaction.formattedDate} • ${transaction.formattedTime}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              transaction.pointsWithPrefix,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: transaction.pointsColor,
              ),
            ),
            Text(
              'points',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        onTap: () {
          _showTransactionDetails(transaction);
        },
      ),
    );
  }

  String _getActionTitle(String action) {
    switch (action) {
      case 'scan':
        return 'QR Scan';
      case 'transfer_in':
        return 'Points Received';
      case 'transfer_out':
        return 'Points Sent';
      default:
        return 'Transaction';
    }
  }

  void _showTransactionDetails(HistoryModel transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Header with icon and title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: transaction.colorValue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      transaction.iconData,
                      color: transaction.colorValue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getActionTitle(transaction.action),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction.formattedDate,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    transaction.pointsWithPrefix,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: transaction.pointsColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              // Details
              Text(
                'Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                transaction.description,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Time information
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    transaction.formattedTime,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}