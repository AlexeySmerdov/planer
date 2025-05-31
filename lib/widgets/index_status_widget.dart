import 'package:flutter/material.dart';
import '../utils/index_monitor.dart';

/// Widget that displays the current status of Firestore indexes
class IndexStatusWidget extends StatefulWidget {
  final bool showDetails;
  final Duration refreshInterval;
  
  const IndexStatusWidget({
    super.key,
    this.showDetails = true,
    this.refreshInterval = const Duration(seconds: 30),
  });
  
  @override
  State<IndexStatusWidget> createState() => _IndexStatusWidgetState();
}

class _IndexStatusWidgetState extends State<IndexStatusWidget> {
  IndexStatusResult? _lastResult;
  bool _isLoading = false;
  bool _autoRefresh = false;
  
  @override
  void initState() {
    super.initState();
    _checkIndexStatus();
  }
  
  Future<void> _checkIndexStatus() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await IndexMonitor.checkIndexStatus();
      setState(() {
        _lastResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to check index status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _toggleAutoRefresh() {
    setState(() {
      _autoRefresh = !_autoRefresh;
    });
    
    if (_autoRefresh) {
      _startAutoRefresh();
    }
  }
  
  void _startAutoRefresh() {
    if (!_autoRefresh) return;
    
    Future.delayed(widget.refreshInterval, () {
      if (_autoRefresh && mounted) {
        _checkIndexStatus().then((_) => _startAutoRefresh());
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Firestore Indexes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _autoRefresh ? Icons.pause : Icons.play_arrow,
                    color: _autoRefresh ? Colors.orange : Colors.green,
                  ),
                  onPressed: _toggleAutoRefresh,
                  tooltip: _autoRefresh ? 'Stop auto-refresh' : 'Start auto-refresh',
                ),
                IconButton(
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _checkIndexStatus,
                  tooltip: 'Refresh status',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusContent(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusContent() {
    if (_isLoading && _lastResult == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_lastResult == null) {
      return const Text('No data available');
    }
    
    if (!_lastResult!.success) {
      return Column(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(
            'Error: ${_lastResult!.error}',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummary(),
        if (widget.showDetails && _lastResult!.indexes.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildIndexList(),
        ],
      ],
    );
  }
  
  Widget _buildSummary() {
    final result = _lastResult!;
    final buildingCount = result.buildingCount;
    final totalCount = result.totalCount;
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    if (buildingCount > 0) {
      statusColor = Colors.orange;
      statusIcon = Icons.build;
      statusText = '$buildingCount of $totalCount indexes building...';
    } else if (totalCount > 0) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'All $totalCount indexes ready';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.info;
      statusText = 'No indexes found';
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (buildingCount > 0)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildIndexList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Index Details:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ..._lastResult!.indexes.map((index) => _buildIndexItem(index)),
      ],
    );
  }
  
  Widget _buildIndexItem(IndexInfo index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                index.stateEmoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Collection: ${index.collectionGroup}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStateColor(index.state).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  index.stateDescription,
                  style: TextStyle(
                    color: _getStateColor(index.state),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (index.fields.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Fields: ${index.fields.map((f) => '${f.fieldPath} (${f.order ?? f.arrayConfig ?? 'N/A'})').join(', ')}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Color _getStateColor(IndexState state) {
    switch (state) {
      case IndexState.creating:
        return Colors.orange;
      case IndexState.ready:
        return Colors.green;
      case IndexState.needsRepair:
        return Colors.amber;
      case IndexState.error:
        return Colors.red;
      case IndexState.unknown:
        return Colors.grey;
    }
  }
}

/// Simple status indicator that can be used in app bars or other compact spaces
class IndexStatusIndicator extends StatefulWidget {
  final VoidCallback? onTap;
  
  const IndexStatusIndicator({super.key, this.onTap});
  
  @override
  State<IndexStatusIndicator> createState() => _IndexStatusIndicatorState();
}

class _IndexStatusIndicatorState extends State<IndexStatusIndicator> {
  bool _isBuilding = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }
  
  Future<void> _checkStatus() async {
    try {
      final isBuilding = await IndexMonitor.areIndexesBuilding();
      setState(() {
        _isBuilding = isBuilding;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isBuilding ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isBuilding ? Icons.build : Icons.check_circle,
              size: 16,
              color: _isBuilding ? Colors.orange : Colors.green,
            ),
            const SizedBox(width: 4),
            Text(
              _isBuilding ? 'Building' : 'Ready',
              style: TextStyle(
                color: _isBuilding ? Colors.orange : Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 