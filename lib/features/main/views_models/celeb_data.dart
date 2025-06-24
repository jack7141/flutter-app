import '../models/celeb_models.dart';

class CelebData {
  static List<CelebModel> getCelebs() {
    return [
      CelebModel.fromJson({
        'name': '이연복',
        'imagePath': 'assets/images/celebs/card.png',
        'description': '요리 전문가',
        'category': '요리',
        'tags': ['1분 요리', '응원/격려'],
      }),
      CelebModel.fromJson({
        'name': '김종국',
        'imagePath': 'assets/images/celebs/kim.png',
        'description': '피트니스 트레이너',
        'category': '운동',
        'tags': ['운동 동기부여', '헬스'],
      }),
      CelebModel.fromJson({
        'name': '아이유',
        'imagePath': 'assets/images/celebs/IU.png',
        'description': '가수 겸 배우',
        'category': '음악',
        'tags': ['위로', '힐링'],
      }),
      CelebModel.fromJson({
        'name': '유재석',
        'imagePath': 'assets/images/celebs/youjea.png',
        'description': '국민 MC',
        'category': '예능',
        'tags': ['유머', '힐링'],
      }),
      CelebModel.fromJson({
        'name': '손흥민',
        'imagePath': 'assets/images/celebs/son.png',
        'description': '축구 선수',
        'category': '스포츠',
        'tags': ['응원', '동기부여'],
      }),
      CelebModel.fromJson({
        'name': '차은우',
        'imagePath': 'assets/images/celebs/card2.png',
        'description': '가수',
        'category': '음악',
        'tags': ['얼굴 조언', '응원'],
      }),
      CelebModel.fromJson({
        'name': 'BTS 지민',
        'imagePath': 'assets/images/celebs/card.png',
        'description': 'K-POP 아티스트',
        'category': '음악',
        'tags': ['위로', '응원'],
      }),
      CelebModel.fromJson({
        'name': '이효리',
        'imagePath': 'assets/images/celebs/card2.png',
        'description': '가수 겸 방송인',
        'category': '음악',
        'tags': ['라이프스타일', '힐링'],
      }),
      CelebModel.fromJson({
        'name': '박서준',
        'imagePath': 'assets/images/celebs/card.png',
        'description': '배우',
        'category': '연기',
        'tags': ['연기 조언', '위로'],
      }),
      CelebModel.fromJson({
        'name': '송강호',
        'imagePath': 'assets/images/celebs/card2.png',
        'description': '배우',
        'category': '연기',
        'tags': ['인생 조언', '응원'],
      }),
    ];
  }
}
