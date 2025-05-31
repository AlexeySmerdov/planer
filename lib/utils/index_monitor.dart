import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility class for monitoring Firestore index building status
class IndexMonitor {
  static const String projectId = 'planner-fe828';
  static const String baseUrl = 'https://firestore.googleapis.com/v1';
  
  /// Check the status of all Firestore indexes
  static Future<IndexStatusResult> checkIndexStatus() async {
    try {
      // Get the current user's ID token for authentication
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final idToken = await user.getIdToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/projects/$projectId/databases/(default)/collectionGroups/-/indexes'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final indexes = (data['indexes'] as List<dynamic>?) ?? [];
        
        final indexStatuses = indexes.map((index) => IndexInfo.fromJson(index)).toList();
        
        return IndexStatusResult(
          success: true,
          indexes: indexStatuses,
          buildingCount: indexStatuses.where((i) => i.state == IndexState.creating).length,
          totalCount: indexStatuses.length,
        );
      } else {
        throw Exception('Failed to fetch indexes: ${response.statusCode}');
      }
    } catch (e) {
      return IndexStatusResult(
        success: false,
        error: e.toString(),
        indexes: [],
        buildingCount: 0,
        totalCount: 0,
      );
    }
  }
  
  /// Check if any indexes are currently building
  static Future<bool> areIndexesBuilding() async {
    final result = await checkIndexStatus();
    return result.success && result.buildingCount > 0;
  }
  
  /// Monitor indexes with periodic checks
  static Stream<IndexStatusResult> monitorIndexes({
    Duration interval = const Duration(seconds: 30),
  }) async* {
    while (true) {
      final result = await checkIndexStatus();
      yield result;
      
      // Stop monitoring if all indexes are ready or if there's an error
      if (!result.success || result.buildingCount == 0) {
        break;
      }
      
      await Future.delayed(interval);
    }
  }
  
  /// Test a query to see if it requires an index
  static Future<QueryTestResult> testQuery({
    required String collection,
    required List<QueryFilter> filters,
    required List<QueryOrder> orderBy,
  }) async {
    try {
      Query query = FirebaseFirestore.instance.collection(collection);
      
      // Apply filters
      for (final filter in filters) {
        query = query.where(filter.field, isEqualTo: filter.value);
      }
      
      // Apply ordering
      for (final order in orderBy) {
        query = query.orderBy(order.field, descending: order.descending);
      }
      
      // Try to execute the query with a limit to minimize data transfer
      final querySnapshot = await query.limit(1).get();
      
      return QueryTestResult(
        success: true,
        requiresIndex: false, // If we got here, the query worked
        message: 'Query executed successfully',
        documentCount: querySnapshot.docs.length,
      );
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition' && 
          e.message?.contains('index') == true) {
        return QueryTestResult(
          success: false,
          requiresIndex: true,
          message: 'Query requires an index: ${e.message}',
          documentCount: 0,
        );
      } else {
        return QueryTestResult(
          success: false,
          requiresIndex: false,
          message: 'Query failed: ${e.message}',
          documentCount: 0,
        );
      }
    } catch (e) {
      return QueryTestResult(
        success: false,
        requiresIndex: false,
        message: 'Unexpected error: $e',
        documentCount: 0,
      );
    }
  }
}

/// Represents the state of a Firestore index
enum IndexState {
  creating,
  ready,
  needsRepair,
  error,
  unknown,
}

/// Information about a single Firestore index
class IndexInfo {
  final String name;
  final String collectionGroup;
  final IndexState state;
  final List<IndexField> fields;
  
  IndexInfo({
    required this.name,
    required this.collectionGroup,
    required this.state,
    required this.fields,
  });
  
  factory IndexInfo.fromJson(Map<String, dynamic> json) {
    final stateString = json['state'] as String? ?? 'UNKNOWN';
    final state = _parseIndexState(stateString);
    
    final fieldsJson = json['fields'] as List<dynamic>? ?? [];
    final fields = fieldsJson.map((f) => IndexField.fromJson(f)).toList();
    
    return IndexInfo(
      name: json['name'] as String? ?? '',
      collectionGroup: json['collectionGroup'] as String? ?? '',
      state: state,
      fields: fields,
    );
  }
  
  static IndexState _parseIndexState(String state) {
    switch (state) {
      case 'CREATING':
        return IndexState.creating;
      case 'READY':
        return IndexState.ready;
      case 'NEEDS_REPAIR':
        return IndexState.needsRepair;
      case 'ERROR':
        return IndexState.error;
      default:
        return IndexState.unknown;
    }
  }
  
  String get stateDescription {
    switch (state) {
      case IndexState.creating:
        return 'Building...';
      case IndexState.ready:
        return 'Ready';
      case IndexState.needsRepair:
        return 'Needs Repair';
      case IndexState.error:
        return 'Error';
      case IndexState.unknown:
        return 'Unknown';
    }
  }
  
  String get stateEmoji {
    switch (state) {
      case IndexState.creating:
        return '🔄';
      case IndexState.ready:
        return '✅';
      case IndexState.needsRepair:
        return '⚠️';
      case IndexState.error:
        return '❌';
      case IndexState.unknown:
        return '❓';
    }
  }
}

/// Represents a field in a Firestore index
class IndexField {
  final String fieldPath;
  final String? order;
  final String? arrayConfig;
  
  IndexField({
    required this.fieldPath,
    this.order,
    this.arrayConfig,
  });
  
  factory IndexField.fromJson(Map<String, dynamic> json) {
    return IndexField(
      fieldPath: json['fieldPath'] as String? ?? '',
      order: json['order'] as String?,
      arrayConfig: json['arrayConfig'] as String?,
    );
  }
}

/// Result of checking index status
class IndexStatusResult {
  final bool success;
  final List<IndexInfo> indexes;
  final int buildingCount;
  final int totalCount;
  final String? error;
  
  IndexStatusResult({
    required this.success,
    required this.indexes,
    required this.buildingCount,
    required this.totalCount,
    this.error,
  });
}

/// Filter for testing queries
class QueryFilter {
  final String field;
  final dynamic value;
  
  QueryFilter({required this.field, required this.value});
}

/// Order clause for testing queries
class QueryOrder {
  final String field;
  final bool descending;
  
  QueryOrder({required this.field, this.descending = false});
}

/// Result of testing a query
class QueryTestResult {
  final bool success;
  final bool requiresIndex;
  final String message;
  final int documentCount;
  
  QueryTestResult({
    required this.success,
    required this.requiresIndex,
    required this.message,
    required this.documentCount,
  });
} 