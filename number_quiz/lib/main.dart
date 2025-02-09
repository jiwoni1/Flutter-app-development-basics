import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

/// 홈 페이지
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String quiz = "";

  @override
  void initState() {
    super.initState();
    getQuiz();
  }

  /// 초기에 퀴즈 가져오기
  void getQuiz() async {
    quiz = await getNumberTrivia();
    setState(
        () {}); // initstate 안에는 async await를 넣을 수 없음, 그래서 함수 새로 생성해서 호출하는 방식으로
  }

  /// Numbers API 호출하기
  Future<String> getNumberTrivia() async {
    // get 메소드로 URL 호출
    Response result = await Dio().get('http://numbersapi.com/random/trivia');
    String trivia = result.data; // 응답 결과 가져오기
    print(trivia);
    return trivia;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 219, 232, 204),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // quiz
              Expanded(
                // Expanded 부모안에서 자기가 차지할 수 있는 비율을 최대로 늘려주는
                child: Center(
                  child: Text(
                    quiz,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // New Quiz 버튼
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  // 그래서 밀려남
                  child: Text(
                    "New Quiz",
                    style: TextStyle(
                      color: Colors.pinkAccent,
                      fontSize: 24,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  onPressed: () {
                    // New Quiz 클릭시 퀴즈 가져오기
                    getQuiz();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
