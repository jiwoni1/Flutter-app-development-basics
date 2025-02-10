import 'package:bucket_list_with_firebase/auth_service.dart';
import 'package:bucket_list_with_firebase/bucket_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // main 함수에서 async 사용하기 위함
  await Firebase.initializeApp(); // firebase 앱 시작
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(
            create: (context) => BucketService()), // 위젯트리 최상단에 올리기
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = context.read<AuthService>().currentUser();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: user == null ? LoginPage() : HomePage(),
    );
  }
}

/// 로그인 페이지
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        User? user = authService.currentUser();
        return Scaffold(
          appBar: AppBar(title: Text("로그인")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// 현재 유저 로그인 상태
                Center(
                  child: Text(
                    user == null ? "로그인해 주세요 🙂" : "${user.email}님 안녕하세요 👋",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
                SizedBox(height: 32),

                /// 이메일
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(hintText: "이메일"),
                ),

                /// 비밀번호
                TextField(
                  controller: passwordController,
                  obscureText: false, // 비밀번호 안보이게
                  decoration: InputDecoration(hintText: "비밀번호"),
                ),
                SizedBox(height: 32),

                /// 로그인 버튼
                ElevatedButton(
                  child: Text("로그인", style: TextStyle(fontSize: 21)),
                  onPressed: () {
// 로그인
                    authService.signIn(
                      email: emailController.text,
                      password: passwordController.text,
                      onSuccess: () {
                        // 로그인 성공
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("로그인 성공"),
                        ));

                        // HomePage로 이동
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      onError: (err) {
                        // 에러 발생
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(err),
                        ));
                      },
                    );
                  },
                ),

                /// 회원가입 버튼
                ElevatedButton(
                  child: Text("회원가입", style: TextStyle(fontSize: 21)),
                  onPressed: () {
                    // 회원가입
                    authService.signUp(
                      email: emailController.text,
                      password: passwordController.text,
                      onSuccess: () {
                        // 회원가입 성공
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("회원가입 성공"),
                        ));
                      },
                      onError: (err) {
                        // 에러 발생
                        print("회원가입 실패 : $err");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(err),
                        ));
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 홈페이지
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController jobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // BucketService Provider를 구독할 수 있도록 Consumer로 감싸주기
    // 이제 BucketService에 접근해서 정보를 가져오고 업데이트하고 구현할 수 있음
    return Consumer<BucketService>(
      // Consumer로 바꾸면 builder 함수의 파라미터가 3개
      // 두번째는 위젯트리 꼭대기에서 찾은 BucketService를 받을 변수
      builder: (context, bucketService, child) {
        // AuthService에 접근해 현재 로그인된 유저 정보 가져오기
        final authService = context.read<AuthService>();
        // User? user = authService.currentUser();  // user가 null일 수가 없을때 User뒤에 ? 물음표를 지우고자하면
        // 뒤에 느낌표를 짝어주기
        // 뒤에 느낌표를 찍으면 이 아이는 절때 null이 아니다 라고 도장을 찍어주는 것 (null값 보증 연산자)
        User user = authService.currentUser()!;
        // print(user.uid);
        return Scaffold(
          appBar: AppBar(
            title: Text("버킷 리스트"),
            actions: [
              TextButton(
                child: Text("로그아웃"),
                onPressed: () {
                  // 로그아웃
                  // consumer로 감싸져있지않을때, 1회성으로 provider를 구독하기위해 사용
                  context.read<AuthService>().signOut();

                  // 로그인 페이지로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              /// 입력창
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    /// 텍스트 입력창
                    Expanded(
                      child: TextField(
                        controller: jobController,
                        decoration: InputDecoration(
                          hintText: "하고 싶은 일을 입력해주세요.",
                        ),
                      ),
                    ),

                    /// 추가 버튼
                    ElevatedButton(
                      child: Icon(Icons.add),
                      onPressed: () {
                        // create bucket
                        // jobController : 텍스트필드와 연결된 컨드롤러
                        if (jobController.text.isNotEmpty) {
                          bucketService.create(jobController.text, user.uid);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Divider(height: 1),

              /// 버킷 리스트
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                    // read 함수가 firebase로 데이터를 요청
                    // 응답이 오기전에 밑에 builder 부분이 실행됨
                    future: bucketService.read(user.uid),
                    builder: (context, snapshot) {
                      // 그래서 snapshot에게 data를 가지고 있냐 물어보면 없다고 함(false)
                      print(snapshot
                          .hasData); // 이후에 파이어베이스에서 응답을 받으면 그때 데이터를 넘겨 받는데, 이 데이터를 스냅샷으로 넘겨주는 것임
                      // 그 다음 빌더부분이 다시 실행됨 (빌더 부분이 2번실행됨, 데이터를 요청할 때와 받을 때)
                      // 최종적으로 넘겨받은 데이터는 snapshot.data라고하면 꺼낼 수 있음 <> 꺽쇠로 친 값을 받아오는 것
                      final documents =
                          snapshot.data?.docs ?? []; // ?.: 응답 받기전에는 null 이므로
                      // documents가 비어있다면 텍스트 위젯
                      if (documents.isEmpty) {
                        return Center(child: Text("버킷리스트를 작성해주세요"));
                      }
                      return ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final doc = documents[index]; // 하나의 문서
                          String job = doc.get("job"); // key값으로 doc값 가져오기
                          bool isDone = doc.get("isDone");
                          return ListTile(
                            title: Text(
                              job,
                              style: TextStyle(
                                fontSize: 24,
                                color: isDone ? Colors.grey : Colors.black,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            // 삭제 아이콘 버튼
                            trailing: IconButton(
                              icon: Icon(CupertinoIcons.delete),
                              onPressed: () {
                                // 삭제 버튼 클릭시
                                bucketService.delete(doc.id);
                              },
                            ),
                            onTap: () {
                              // 아이템 클릭하여 isDone 업데이트
                              // isDone값을 느낌표를 앞에 붙여서 반전시켜서 전달
                              bucketService.update(doc.id, !isDone);
                            },
                          );
                        },
                      );
                    }),
              ),
            ],
          ),
        );
      },
    );
  }
}
