import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'HomeScreen.dart';
import 'auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isArabic = false;
  int selectedAvatar = 2;
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> registerUser() async {
    if (isLoading) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage(
        isArabic
            ? 'من فضلك املئي جميع الحقول المطلوبة'
            : 'Please fill in all required fields',
      );
      return;
    }

    if (password != confirmPassword) {
      showMessage(
        isArabic
            ? 'كلمتا المرور غير متطابقتين'
            : 'Passwords do not match',
      );
      return;
    }

    if (password.length < 6) {
      showMessage(
        isArabic
            ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
            : 'Password must be at least 6 characters',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await AuthService().register(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'network-request-failed':
          message = 'Please check your internet connection';
          break;
        case 'operation-not-allowed':
          message = 'Email/Password sign-in is not enabled in Firebase';
          break;
        default:
          message = 'Registration failed. Please try again';
      }

      showMessage(message);
    } catch (e) {
      if (!mounted) return;
      showMessage('Something went wrong. Please try again');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFF6BD00);
    const bg = Color(0xFF121312);

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // HEADER
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: yellow,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: yellow,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // AVATARS
                  SizedBox(
                    height: 145,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        avatarButton(1),
                        const SizedBox(width: 5),
                        avatarButton(2),
                        const SizedBox(width: 5),
                        avatarButton(3),
                      ],
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Avatar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // NAME
                  buildField(
                    controller: nameController,
                    icon: Icons.badge_outlined,
                    hint: isArabic ? 'الاسم' : 'Name',
                  ),

                  const SizedBox(height: 20),

                  // EMAIL
                  buildField(
                    controller: emailController,
                    icon: Icons.email,
                    hint: isArabic ? 'البريد الإلكتروني' : 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD
                  buildField(
                    controller: passwordController,
                    icon: Icons.lock,
                    hint: isArabic ? 'كلمة المرور' : 'Password',
                    obscure: hidePassword,
                    suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CONFIRM PASSWORD
                  buildField(
                    controller: confirmPasswordController,
                    icon: Icons.lock,
                    hint: isArabic
                        ? 'تأكيد كلمة المرور'
                        : 'Confirm Password',
                    obscure: hideConfirmPassword,
                    suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          hideConfirmPassword = !hideConfirmPassword;
                        });
                      },
                      icon: Icon(
                        hideConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PHONE
                  buildField(
                    controller: phoneController,
                    icon: Icons.phone,
                    hint: isArabic ? 'رقم الهاتف' : 'Phone Number',
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 20),

                  // CREATE ACCOUNT
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellow,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                          : Text(
                        isArabic
                            ? 'إنشاء حساب'
                            : 'Create Account',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // LOGIN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isArabic
                            ? 'لديك حساب بالفعل؟ '
                            : 'Already Have Account ? ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: yellow,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // LANGUAGE SWITCH
                  Container(
                    width: 96,
                    height: 43.7,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: yellow,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          left: isArabic ? 52 : 0,
                          top: 0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: yellow,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        // USA FLAG
                        Positioned(
                          left: 0,
                          top: 0,
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isArabic = false;
                              });
                            },
                            child: Center(
                              child: Image.asset(
                                'assets/Us.png',
                                width: 26.88,
                                height: 26.88,
                              ),
                            ),
                          ),
                        ),

                        // EGYPT FLAG
                        Positioned(
                          right: 0,
                          top: 0,
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isArabic = true;
                              });
                            },
                            child: Center(
                              child: Image.asset(
                                'assets/Eg.png',
                                width: 26.88,
                                height: 26.88,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // AVATAR BUTTON
  Widget avatarButton(int number) {
    const yellow = Color(0xFFF6BD00);

    final isSelected = selectedAvatar == number;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAvatar = number;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        width: isSelected ? 135 : 85,
        height: isSelected ? 135 : 85,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: EdgeInsets.all(isSelected ? 3 : 0),
        decoration: BoxDecoration(
          color: isSelected ? yellow : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/Avatar$number.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // TEXT FIELD
  Widget buildField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    const field = Color(0xFF282A28);

    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white,
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: field,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}