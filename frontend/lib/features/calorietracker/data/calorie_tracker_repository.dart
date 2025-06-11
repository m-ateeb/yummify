import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/features/calorietracker/domain/calorie_entry.dart';

class CalorieTrackerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _user => _auth.currentUser;

  /// Add a new calorie entry with user ID
  Future<void> addEntry(CalorieEntry entry) async {
    if (_user == null) throw Exception('User not logged in');
    final data = entry.toMap()..['userId'] = _user!.uid;
    await _firestore.collection('calorie_entries').add(data);
  }

  /// Stream all entries for the current user
  Stream<List<CalorieEntry>> getEntries() {
    if (_user == null) return Stream.value([]);
    return _firestore
        .collection('calorie_entries')
        .where('userId', isEqualTo: _user!.uid)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => CalorieEntry.fromMap(doc.data(), doc.id)).toList());
  }

  /// Filter entries by day, month, or year
  Future<List<CalorieEntry>> getEntriesByDate({
    DateTime? day,
    DateTime? month,
    DateTime? year,
  }) async {
    if (_user == null) return [];

    Timestamp start, end;

    if (day != null) {
      start = Timestamp.fromDate(DateTime(day.year, day.month, day.day));
      end = Timestamp.fromDate(DateTime(day.year, day.month, day.day + 1));
    } else if (month != null) {
      start = Timestamp.fromDate(DateTime(month.year, month.month));
      end = Timestamp.fromDate(DateTime(month.year, month.month + 1));
    } else if (year != null) {
      start = Timestamp.fromDate(DateTime(year.year));
      end = Timestamp.fromDate(DateTime(year.year + 1));
    } else {
      throw Exception('At least one filter (day/month/year) must be provided');
    }

    final query = await _firestore
        .collection('calorie_entries')
        .where('userId', isEqualTo: _user!.uid)
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThan: end)
        .get();

    return query.docs.map((doc) => CalorieEntry.fromMap(doc.data(), doc.id)).toList();
  }

  /// Search meals by name (case-insensitive substring search)
  Future<List<CalorieEntry>> searchMeals(String keyword) async {
    if (_user == null) return [];

    final query = await _firestore
        .collection('calorie_entries')
        .where('userId', isEqualTo: _user!.uid)
        .get();

    return query.docs
        .map((doc) => CalorieEntry.fromMap(doc.data(), doc.id))
        .where((entry) =>
        entry.mealName.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  Stream<List<CalorieEntry>> getEntriesForDay(DateTime date) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    return _firestore
        .collection('calorie_entries')
        .where('userId', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CalorieEntry.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Fetch entries for a specific month
  Stream<List<CalorieEntry>> getEntriesForMonth(int year, int month) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 1);

    return _firestore
        .collection('calorie_entries')
        .where('userId', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
        .where('timestamp', isLessThan: endOfMonth)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CalorieEntry.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Fetch entries for a specific year
  Stream<List<CalorieEntry>> getEntriesForYear(int year) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final startOfYear = DateTime(year, 1, 1);
    final endOfYear = DateTime(year + 1, 1, 1);

    return _firestore
        .collection('calorie_entries')
        .where('userId', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfYear)
        .where('timestamp', isLessThan: endOfYear)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CalorieEntry.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// Update an entry
  Future<void> updateEntry(String id, CalorieEntry entry) async {
    if (_user == null) throw Exception('User not logged in');
    final data = entry.toMap()..['userId'] = _user!.uid;
    await _firestore.collection('calorie_entries').doc(id).update(data);
  }

  /// Delete an entry
  Future<void> deleteEntry(String id) async {
    if (_user == null) throw Exception('User not logged in');
    await _firestore.collection('calorie_entries').doc(id).delete();
  }

  /// Set a goal (daily, weekly, or monthly)
  // Future<void> setGoal(String period, int calorieLimit) async {
  //   if (_user == null) throw Exception('User not logged in');
  //   await _firestore
  //       .collection('user_goals')
  //       .doc(_user!.uid)
  //       .set({period: calorieLimit}, SetOptions(merge: true));
  // }

  /// Check goal for the given period
  Future<bool> checkGoalAchieved(String period) async {
    if (_user == null) throw Exception('User not logged in');

    DateTime now = DateTime.now();
    DateTime start;

    if (period == 'daily') {
      start = DateTime(now.year, now.month, now.day);
    } else if (period == 'weekly') {
      start = now.subtract(Duration(days: now.weekday - 1));
    } else if (period == 'monthly') {
      start = DateTime(now.year, now.month);
    } else {
      throw Exception('Invalid period');
    }

    final end = now;
    final query = await _firestore
        .collection('calorie_entries')
        .where('userId', isEqualTo: _user!.uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    final totalCalories = query.docs
        .map((doc) => CalorieEntry.fromMap(doc.data(), doc.id).calories)
        .fold<int>(0, (sum, cal) => sum + cal);

    final goalDoc =
    await _firestore.collection('user_goals').doc(_user!.uid).get();
    final goal = goalDoc.data()?[period];

    if (goal == null) throw Exception('Goal not set for $period');

    return totalCalories <= goal;
  }

  // Set a new goal
  Future<void> setGoal(Goal goal) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore.collection('goals').add({
      'userId': user.uid,
      'targetCalories': goal.targetCalories,
      'startDate': goal.startDate,
      'endDate': goal.endDate,
      'type': goal.type.index,
    });
  }
  // Add this to lib/features/calorietracker/data/calorie_tracker_repository.dart

  Future<void> deleteGoal(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore.collection('goals').doc(id).delete();
  }

  // Add to CalorieTrackerRepository

  Future<void> updateGoal(Goal goal) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore.collection('goals').doc(goal.id).update({
      'targetCalories': goal.targetCalories,
      'startDate': goal.startDate,
      'endDate': goal.endDate,
      'type': goal.type.index,
    });
  }

  // Check if the user has achieved their goal
  Future<bool> checkGoalAchievement(Goal goal) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final entries = await _firestore
        .collection('calorie_entries')
        .where('userId', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: goal.startDate)
        .where('timestamp', isLessThanOrEqualTo: goal.endDate)
        .get();

    final totalCalories = entries.docs.fold(0.0, (sum, doc) {
      final entry = CalorieEntry.fromMap(doc.data(), doc.id);
      return sum + entry.calories;
    });

    return totalCalories >= goal.targetCalories;
  }

  Stream<List<Goal>> getCurrentGoals() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    final now = DateTime.now();

    return _firestore
        .collection('goals')
        .where('userId', isEqualTo: user.uid)
        .where('endDate', isGreaterThanOrEqualTo: now)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Goal.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Notify user about goal achievement
  Future<void> notifyGoalAchievement(Goal goal) async {
    final achieved = await checkGoalAchievement(goal);
    if (achieved) {
      // Implement notification logic here
    }
  }
}
