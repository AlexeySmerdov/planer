# 🚀 Quick Start: Check Firestore Index Status

## ⚡ Immediate Status Check (Choose One)

### Option 1: Firebase CLI (Fastest)
```bash
firebase firestore:indexes
```

### Option 2: PowerShell Script (Windows)
```powershell
.\scripts\check-indexes.ps1
```

### Option 3: Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/project/planner-fe828/firestore/indexes)
2. Check the "Status" column

## 🔄 Continuous Monitoring

### PowerShell (Windows)
```powershell
# Monitor every 30 seconds
.\scripts\check-indexes.ps1 -Monitor

# Monitor every 60 seconds
.\scripts\check-indexes.ps1 -Monitor -Interval 60
```

### Node.js Script (Advanced)
```bash
cd scripts
npm install
npm run monitor
```

## 📱 In Your Flutter App

### Add to any widget:
```dart
import 'package:planner/widgets/index_status_widget.dart';

// Full status widget
IndexStatusWidget(showDetails: true)

// Compact indicator
IndexStatusIndicator(
  onTap: () => print('Show index details'),
)
```

### Check programmatically:
```dart
import 'package:planner/utils/index_monitor.dart';

// Quick check
final isBuilding = await IndexMonitor.areIndexesBuilding();
print('Indexes building: $isBuilding');

// Detailed status
final result = await IndexMonitor.checkIndexStatus();
print('${result.buildingCount}/${result.totalCount} indexes building');
```

## 📊 Current Status

Your project **planner-fe828** has:
- ✅ **1 index** on `tasks` collection
- 🔧 **Fields**: `userId` (ascending), `dueDate` (ascending)
- 🎯 **Status**: Ready and working

## 🆘 If Indexes Are Building

1. **Be patient** - Large datasets can take hours
2. **Monitor progress** using any method above
3. **Don't deploy** new code until indexes are ready
4. **Check Firebase Console** for detailed progress

## 🔧 Quick Commands Reference

```bash
# Check status
firebase firestore:indexes

# Deploy new indexes
firebase deploy --only firestore:indexes

# Monitor with PowerShell
.\scripts\check-indexes.ps1 -Monitor

# Get Flutter dependencies
flutter pub get
```

---

**Need help?** Check the full guide: `INDEX_MONITORING_GUIDE.md` 