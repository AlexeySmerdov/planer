# Firestore Index Monitoring Guide

This guide provides multiple methods to check the status of index building in your Firebase Firestore project.

## 🎯 Quick Status Check

### Method 1: Firebase CLI (Fastest)
```bash
# Check current indexes configuration
firebase firestore:indexes

# Deploy indexes and monitor
firebase deploy --only firestore:indexes
```

### Method 2: Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `planner-fe828`
3. Navigate to **Firestore Database** → **Indexes**
4. Check the status column for each index

## 🔧 Advanced Monitoring Tools

### Node.js Script (Detailed Status)

#### Setup
1. Install dependencies:
```bash
cd scripts
npm install
```

2. Download your service account key:
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate new private key"
   - Save as `scripts/service-account-key.json`

#### Usage
```bash
# One-time status check
npm run check

# Continuous monitoring (checks every 30 seconds)
npm run monitor

# Fast monitoring (checks every 10 seconds)
npm run monitor-fast

# Custom interval monitoring
node check_index_status.js --monitor 60
```

### Flutter/Dart Integration

#### Setup
Add the HTTP dependency to your `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
```

#### Usage in your Flutter app:
```dart
import 'package:your_app/utils/index_monitor.dart';
import 'package:your_app/widgets/index_status_widget.dart';

// Check status once
final result = await IndexMonitor.checkIndexStatus();
print('Building indexes: ${result.buildingCount}/${result.totalCount}');

// Monitor continuously
IndexMonitor.monitorIndexes().listen((result) {
  print('Status update: ${result.buildingCount} indexes building');
});

// Test if a query needs an index
final queryResult = await IndexMonitor.testQuery(
  collection: 'tasks',
  filters: [QueryFilter(field: 'userId', value: 'user123')],
  orderBy: [QueryOrder(field: 'dueDate')],
);

// Use the widget in your app
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
        actions: [
          IndexStatusIndicator(
            onTap: () => _showIndexDetails(context),
          ),
        ],
      ),
      body: Column(
        children: [
          IndexStatusWidget(showDetails: true),
          // ... rest of your app
        ],
      ),
    );
  }
}
```

## 📊 Understanding Index States

| State | Emoji | Description | Action Needed |
|-------|-------|-------------|---------------|
| `CREATING` | 🔄 | Index is being built | Wait for completion |
| `READY` | ✅ | Index is ready for use | None |
| `NEEDS_REPAIR` | ⚠️ | Index needs repair | Contact Firebase support |
| `ERROR` | ❌ | Index creation failed | Check configuration |

## 🚀 Current Project Status

Your project (`planner-fe828`) currently has:
- **1 composite index** on the `tasks` collection
- **Fields**: `userId` (ascending), `dueDate` (ascending)
- **Status**: Ready ✅

## 💡 Best Practices

### 1. Monitor During Deployment
```bash
# Deploy and monitor in one command
firebase deploy --only firestore:indexes && npm run monitor
```

### 2. Automated Monitoring in CI/CD
```yaml
# GitHub Actions example
- name: Deploy Firestore Indexes
  run: firebase deploy --only firestore:indexes

- name: Wait for Indexes
  run: |
    cd scripts
    npm install
    timeout 300 npm run monitor || echo "Timeout reached"
```

### 3. Query Testing
Before deploying new indexes, test your queries:
```dart
// Test the query that requires your index
final testResult = await IndexMonitor.testQuery(
  collection: 'tasks',
  filters: [QueryFilter(field: 'userId', value: 'test')],
  orderBy: [QueryOrder(field: 'dueDate')],
);

if (testResult.requiresIndex) {
  print('Index needed: ${testResult.message}');
}
```

## 🔍 Troubleshooting

### Common Issues

1. **Authentication Error**
   - Ensure you're logged in: `firebase login`
   - Check service account permissions

2. **Index Building Takes Too Long**
   - Large datasets can take hours
   - Monitor progress with continuous monitoring
   - Check Firebase Console for detailed progress

3. **Query Still Fails After Index is Ready**
   - Clear app cache
   - Restart your app
   - Verify index configuration matches query

### Debug Commands
```bash
# Check Firebase project
firebase projects:list

# Verify current project
firebase use

# Check authentication
firebase auth:list

# View detailed logs
firebase functions:log
```

## 📱 Integration Examples

### Add to App Bar
```dart
AppBar(
  title: Text('Planner'),
  actions: [
    IndexStatusIndicator(
      onTap: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: IndexStatusWidget(),
        ),
      ),
    ),
  ],
)
```

### Settings Page
```dart
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // ... other settings
          IndexStatusWidget(
            showDetails: true,
            refreshInterval: Duration(seconds: 15),
          ),
        ],
      ),
    );
  }
}
```

### Background Monitoring
```dart
class IndexBackgroundMonitor {
  static Timer? _timer;
  
  static void startMonitoring() {
    _timer = Timer.periodic(Duration(minutes: 5), (timer) async {
      final isBuilding = await IndexMonitor.areIndexesBuilding();
      if (!isBuilding) {
        // All indexes ready, stop monitoring
        timer.cancel();
        _showNotification('All Firestore indexes are ready!');
      }
    });
  }
  
  static void stopMonitoring() {
    _timer?.cancel();
  }
}
```

## 🎉 Next Steps

1. **Set up monitoring**: Choose your preferred method and set it up
2. **Test your queries**: Use the query testing feature to verify indexes
3. **Integrate into your app**: Add the Flutter widgets to your UI
4. **Automate**: Set up CI/CD monitoring for deployments

## 📞 Support

If you encounter issues:
1. Check the [Firebase documentation](https://firebase.google.com/docs/firestore/query-data/indexing)
2. Review the [Firebase status page](https://status.firebase.google.com/)
3. Contact Firebase support through the console

---

**Happy indexing! 🚀** 