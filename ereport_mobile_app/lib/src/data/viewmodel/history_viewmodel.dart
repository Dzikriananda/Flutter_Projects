import 'package:ereport_mobile_app/src/core/utils/helpers.dart';
import 'package:ereport_mobile_app/src/data/auth/firestore_repository.dart';
import 'package:ereport_mobile_app/src/data/models/daily_log_summary.dart';
import 'package:ereport_mobile_app/src/data/models/list_log_model.dart';
import 'package:flutter/material.dart';
import '../../core/constants/result_state.dart';
import '../auth/auth.dart';

class HistoryViewModel extends ChangeNotifier {
  late ResultState _state;
  late Auth auth;
  late Firestore firestore;
  late Map<String,dynamic> _log;
  late DateTime _focusDate;
  late DailyLogSummary _logSummary;
  late List<LogModel> _activityList;
  String? _currentDate;


  HistoryViewModel() {
    _state = ResultState.started;
    auth = Auth();
    firestore = Firestore();
    _focusDate = DateTime.now();
    _currentDate = convertDate(DateTime.now());
    _logSummary = DailyLogSummary(0,0,0);
    _log = {};
    _activityList = [];
  }

  void disposeViewModel(){
    _state = ResultState.started;
    _currentDate = null;
  }

  DateTime get focusDate => _focusDate;
  String? get currentDate => _currentDate;
  Map<String,dynamic> get log => _log;
  ResultState get state => _state;
  DailyLogSummary get logSummary => _logSummary;
  List<LogModel> get activityList => _activityList;

  set focusDate(DateTime inputDate) {
    String date = convertDate(inputDate);
    _focusDate = inputDate;
    _currentDate = date;
    _getLog();
    notifyListeners();
  }

  Future<void> _getLog() async {
    _state = ResultState.loading;
    notifyListeners();
    final uid = await auth.getCurrentUID();
    _log = await firestore.getLogByDate(uid!, currentDate!);
    print(_log.length);
    if (_log.length == 0) {
      _logSummary.burnedCalories = 0;
      _logSummary.consumedCalories = 0;
      _logSummary.calorieBudget = 0;
      _logSummary.remainingCalories = 0;
      _state = ResultState.noData;
    }
    else {
      _logSummary = _log['logSummary'];
      _activityList = _log['logList'];
      final remainingCal = _logSummary.calorieBudget! - (_logSummary.consumedCalories! - _logSummary.burnedCalories!);
      final cal = remainingCal.toStringAsFixed(1);
      _logSummary.remainingCalories = double.parse(cal);
      print(remainingCal);
      _state = ResultState.hasData;
    }
    notifyListeners();
  }



}