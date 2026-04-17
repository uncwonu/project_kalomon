import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class login_screen extends StatefulWidget {
  const login_screen({super.key});

  @override
  State<login_screen> createState() => _login_screenState();
}

class _login_screenState extends State<login_screen> {
  var emailController = TextEditingController();
  var passController = TextEditingController();
  var nameController = TextEditingController(); // 🚀 신규: 이름(닉네임) 입력 컨트롤러

  bool isLoginMode = true;

  Future<bool> loginWithGoogle() async {
    try {
      // 🚨 1. 최신 문법: instance.initialize() 안에 아이디를 넣어서 세팅합니다.
      await GoogleSignIn.instance.initialize(
        serverClientId: '966224291372-th5nc084tpi6nnnnh2q4btv5tk1o6gr0.apps.googleusercontent.com',
      );

      // 🚨 2. 최신 문법: signIn() 대신 authenticate()를 사용합니다.
      final user = await GoogleSignIn.instance.authenticate();
      if (user == null) return false;

      final GoogleSignInAuthentication userAuth = await user.authentication;

      var credential = GoogleAuthProvider.credential(
        idToken: userAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      return FirebaseAuth.instance.currentUser != null;
    } catch (e) {
      debugPrint("구글 로그인 에러: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                const Icon(Icons.fitness_center, size: 60, color: Colors.amber),
                const Text(
                  'KALOMON',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber),
                ),

                const SizedBox(height: 10),
                Text(
                  isLoginMode ? '환영합니다!' : '새로운 계정을 만드세요',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 30),

                // 🚀 신규: 회원가입 모드일 때만 '이름' 입력칸이 스르륵 나타남!
                if (!isLoginMode) ...[
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter Name (닉네임)",
                      labelStyle: TextStyle(color: Colors.amberAccent),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],

                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter Email",
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 25),

                TextField(
                  controller: passController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter Password",
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 35),

                ElevatedButton(
                  onPressed: () async {
                    String mail = emailController.text.trim();
                    String pass = passController.text.trim();
                    String name = nameController.text.trim();

                    if (mail.isEmpty || pass.isEmpty || (!isLoginMode && name.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("모든 정보를 입력해주세요.")));
                      return;
                    }

                    try {
                      if (isLoginMode) {
                        // 🚀 1. 로그인 로직 (인증 검사 포함)
                        UserCredential userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: mail, password: pass);

                        // 이메일 인증을 안 한 얌체 유저 입구컷!
                        if (!userCred.user!.emailVerified) {
                          await FirebaseAuth.instance.signOut(); // 강제 로그아웃
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🚨 이메일 인증이 필요합니다! 메일함을 확인해주세요.")));
                          }
                          return;
                        }

                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${userCred.user!.displayName}님 환영합니다!")));

                      } else {
                        // 🚀 2. 회원가입 로직 (이메일 발송 포함)
                        UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: mail, password: pass);
                        User? user = userCred.user;

                        if (user != null) {
                          await user.updateDisplayName(name); // 파이어베이스에 이름 저장
                          await user.sendEmailVerification(); // 💌 파이어베이스가 알아서 인증 메일 발송!
                          await FirebaseAuth.instance.signOut(); // 가입 직후 자동 로그인 방지 (인증해야 들어오게)

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text("✅ 가입 완료! 입력하신 이메일로 인증 링크를 보냈습니다. 클릭 후 로그인해주세요."),
                              duration: Duration(seconds: 5), // 메시지를 좀 더 길게 보여줌
                            ));
                            setState(() {
                              isLoginMode = true; // 메일 보냈으니 다시 로그인 화면으로 스위치
                              passController.clear(); // 비밀번호 초기화
                            });
                          }
                        }
                      }
                    } on FirebaseAuthException catch (err) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("에러: ${err.message}")));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    isLoginMode ? "Login" : "Sign Up",
                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 25),

                InkWell(
                  onTap: () {
                    setState(() {
                      isLoginMode = !isLoginMode;
                    });
                  },
                  child: Text(
                    isLoginMode ? "New User? Click Here (회원가입)" : "Already have an account? Login",
                    style: const TextStyle(color: Colors.amber),
                  ),
                ),
                const SizedBox(height: 25),

                // 구글 로그인은 구글이 알아서 신원 보증을 하므로 이메일 인증 생략 가능!
                ElevatedButton(
                  onPressed: () async {
                    bool isLogged = await loginWithGoogle();
                    if (isLogged) {
                      debugPrint("Google Login Success!");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png',
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Sign in with Google",
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}