import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ereport_mobile_app/src/core/utils/helpers.dart';
import 'package:ereport_mobile_app/src/data/models/list_log_model.dart';
import 'package:ereport_mobile_app/src/data/models/user.dart';
import 'package:flutter/foundation.dart';

class Firestore {
  final db = FirebaseFirestore.instance;

  Future<UserModel?> getUserData(String UID) async {
    final docRef = db.collection("user");
    try{
      final querySnapshot = await docRef.where("uid", isEqualTo: UID).get();
      for (var docSnapshot in querySnapshot.docs) {
        print('in getUSerData');
        final user = UserModel.fromMap(docSnapshot.data());
        return user;
      }
    } catch(e){
      return null;
    }


  }

  Future<bool?> hasFilledData(String UID) async{
    final docRef = db.collection("user");
    try{
      final querySnapshot = await docRef.where("uid", isEqualTo: UID).get();
      print(querySnapshot.docs);
      for (var docSnapshot in querySnapshot.docs) {
        print(docSnapshot.data());
         return docSnapshot.data()['hasFilledData'];
      }
    } catch(e){
      print("error while fetching : $e");
      return null;
    }
  }

  Future<void> addUser(String uid) async{
    final data = {"uid": uid,"hasFilledData":false};
    try{
      await db.collection("user").add(data).then((documentSnapshot) =>
          debugPrint("Added Data with ID: ${documentSnapshot.id}"));
      await db.collection("log").add({"uid":uid}).then((documentSnapshot) =>
          debugPrint("Added Data with ID: ${documentSnapshot.id}"));
    }
    catch(e){
      debugPrint('error while addUser : $e');
    }
  }

  Future<void> addLog(String uid,Map<String,dynamic> log) async {
    const dataSource = Source.server;
    final docRef = db.collection("log");
    int number = 0;
    late double consumedCalorie;
    String? docId;
    try{
      final querySnapshot = await docRef.where("uid", isEqualTo: uid).get(const GetOptions(source: dataSource));
      for (var docSnapshot in querySnapshot.docs) {
        docId = docSnapshot.id;
      }
      final todayLog = await docRef.doc(docId).collection(getTodayDate());
      final latestLog = await todayLog.orderBy('no',descending: true).limit(1).get();
      for (var docSnapshot in latestLog.docs) {
        number = docSnapshot.data()['no'];
      }
      if(number == null || number == 0){
        // number = 0;
        final user = await getUserData(uid);
        print(user!.calorieNeed);
        final calorieNeed = user!.calorieNeed;
        await todayLog.doc(number.toString()).set({'no':number,'calorieBudget':calorieNeed,'consumedCalories':0});
      }
      number++;
      await todayLog.doc(number.toString()).set({'no':number,...log});
      final docZero = await todayLog.doc('0').get();
      final beforeCalorie = docZero.data()!['consumedCalories'];
      final afterCalorie = beforeCalorie + log['calories'];
      await todayLog.doc('0').update({'consumedCalories':afterCalorie});
    } catch(e){
      print("error while adding : $e");
    }
  }

  Future<Map<String,dynamic>?> getTodayCalorie(String uid) async{
    const dataSource = Source.server;
    final docRef = db.collection("log");
    String? docId;

    try{
      final querySnapshot = await docRef.where("uid", isEqualTo: uid).get(const GetOptions(source: dataSource));
      for (var docSnapshot in querySnapshot.docs) {
        docId = docSnapshot.id;
      }
      final todayLog = await docRef.doc(docId).collection(getTodayDate()).doc('0').get();
      return todayLog.data();
    }
    catch(e){
      print("error $e");
    }
  }

  Future<List<ListLogModel>> getListLog(String uid) async {
    const dataSource = Source.server;
    final docRef = db.collection("log");
    List<ListLogModel> logList=[];
    int i = 0;
    String? docId;
    try{
      final querySnapshot = await docRef.where("uid", isEqualTo: uid).get(const GetOptions(source: dataSource));
      for (var docSnapshot in querySnapshot.docs) {
        docId = docSnapshot.id;
      }
      print('mendapatkan firebase');
      final todayLog = await docRef.doc(docId).collection(getTodayDate()).get();
      for (var docSnapshot in todayLog.docs) {
        if(i!=0){
          logList.add(ListLogModel.fromMap(docSnapshot.data()));
        }
        i++;
      }
      return logList;
    } catch(e){
      print("error while fetching : $e");
      return logList;
    }


  }

  // Future<void> getTodayLog(String uid) async {
  //   const dataSource = Source.server;
  //   final docRef = db.collection("log");
  //   String? docId;
  //   try{
  //     final querySnapshot = await docRef.where("uid", isEqualTo: uid).get(const GetOptions(source: dataSource));
  //     for (var docSnapshot in querySnapshot.docs) {
  //       docId = docSnapshot.id;
  //     }
  //     print('mendapatkan firebase');
  //     docRef.doc(docId).collection('02-11-2023').doc('01').get().then((value) => print(value.data()));
  //   } catch(e){
  //     print("error while fetching : $e");
  //   }
  // }

  Future<void> getTodayLatestLog(String uid) async {
    const dataSource = Source.server;
    final docRef = db.collection("log");
    String? docId;
    try{
      final querySnapshot = await docRef.where("uid", isEqualTo: uid).get(const GetOptions(source: dataSource));
      for (var docSnapshot in querySnapshot.docs) {
        docId = docSnapshot.id;
      }
      final latestLog = await docRef.doc(docId).collection('04-11-2023').orderBy('no',descending: true).limit(1).get();
      for (var docSnapshot in latestLog.docs) {
        print(docSnapshot.data());
      }
    } catch(e){
      print("error while fetching : $e");
    }


  }


  Future<bool> updateUser(String uid, UserModel data) async{
    const dataSource = Source.server;
    final docRef = db.collection("user");
    String? docId;
    try{
      final querySnapshot = await docRef.where("uid", isEqualTo: uid).get(const GetOptions(source: dataSource));
      for (var docSnapshot in querySnapshot.docs) {
          docId = docSnapshot.id;
          print("update user dengan uid : ${docId}");
      }
      docRef.doc(docId).update(data.toMap());
      return true;

    } catch(e){
      print("error while fetching : $e");
      return false;
    }

  }


}