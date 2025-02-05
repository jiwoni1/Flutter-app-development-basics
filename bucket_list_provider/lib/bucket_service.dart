import 'package:flutter/material.dart';

import 'main.dart';

/// Bucket 담당
/// 구독하는 친구들에게 알림을 보내는
class BucketService extends ChangeNotifier {
  List<Bucket> bucketList = [
    Bucket('잠자기', false), // 더미(dummy) 데이터
  ];

  /// bucket 추가
  void createBucket(String job) {
    bucketList.add(Bucket(job, false));
    // 변경사항이 있다면 새로고침하세요
    // consumer의 builder 함수 내부가 다시 실행됨
    notifyListeners();
  }

  /// bucket 수정
  void updateBucket(Bucket bucket, int index) {
    bucketList[index] = bucket;
    notifyListeners();
  }

  /// bucket 삭제
  void deleteBucket(int index) {
    bucketList.removeAt(index);
    notifyListeners();
  }
}
