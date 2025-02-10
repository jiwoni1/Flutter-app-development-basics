import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// 변경사항이 있는 경우 새로고침하기 위해 ChangeNotifier를 상속
class BucketService extends ChangeNotifier {
  // firebase의 컬렉션에 접근하는 코드
  final bucketCollection = FirebaseFirestore.instance.collection('bucket');

  // 시간이 걸리는 반환값이므로 Future 사용
  // flutter에서는 이와 같이 future를 반환하는 결과를 화면에 보여줄 때 future builder라는 widget을 활용함
  Future<QuerySnapshot> read(String uid) async {
    // 내 bucketList 가져오기 (uid와 일치하는)
    return bucketCollection.where('uid', isEqualTo: uid).get();
  }

  void create(String job, String uid) async {
    // bucket 만들기 (document 추가)
    // 서버와 통신하는 코드기 때문에 Future -> await붙히기
    await bucketCollection.add({
      'uid': uid, // 유저 식별자
      'job': job, // 하고싶은 일
      'isDone': false, // 완료 여부
    });
    notifyListeners(); // 화면 갱신
  }

  void update(String docId, bool isDone) async {
    // bucket isDone 업데이트

    // 네트워크 통신을 통해 요청을 보내고, 비동기로 작동하는 코드라서 await 붙히기
    await bucketCollection.doc(docId).update({"isDone": isDone});
    // 업데이트가 다 되면 화면을 새로 고침할 수 있도록
    notifyListeners();
  }

  void delete(String docId) async {
    // bucket 삭제
    // 네트워크 통신을 통해 요청을 보내고, 비동기로 작동하는 코드라서 await 붙히기
    await bucketCollection.doc(docId).delete();

    notifyListeners();
  }
}
