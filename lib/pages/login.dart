import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'signup.dart';
import 'dashboard.dart'; // your dashboard

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login UI',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _loading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse('http://mateogroup.mywebcommunity.org/login.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      setState(() => _loading = false);
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          final prefs = await SharedPreferences.getInstance();
          final user = data['user'] ?? {};

          await prefs.setInt('userId', (user['id'] ?? 0) as int);
          await prefs.setString('name', (user['name'] ?? '') as String);
          await prefs.setString('email', (user['email'] ?? '') as String);

          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ClientDashboard()),
          );
        } else {
          _showDialog('Login Failed', data['message']);
        }
      } else {
        _showDialog('Error', 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _loading = false);
      _showDialog('Error', 'An unexpected error occurred: $e');
    }
  }


  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF8B0000),
                      Color(0xFF6A040F),
                      Color(0xFF5A0208),
                      Color(0xFF4B0000),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              SizedBox(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 100.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const CircleAvatar(
                          radius: 50.0,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person,
                              size: 60.0, color: Color(0xFF6A040F)),
                        ),
                        const SizedBox(height: 20.0),
                        const Text('Sign In',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 35.0,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 30.0),
                        _buildEmailTF(),
                        const SizedBox(height: 30.0),
                        _buildPasswordTF(),
                        _buildForgotPasswordBtn(),
                        const SizedBox(height: 10.0),
                        _buildLoginBtn(),
                        const SizedBox(height: 30.0),
                        _buildSignupBtn(),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTF() {
    return _inputField(
      label: 'Email',
      controller: _emailController,
      icon: Icons.email,
      validator: (v) => (v == null || v.isEmpty || !v.contains('@'))
          ? 'Enter a valid email'
          : null,
    );
  }

  Widget _buildPasswordTF() {
    return _inputField(
      label: 'Password',
      controller: _passwordController,
      icon: Icons.lock,
      obscureText: _obscureText,
      suffix: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.white70,
        ),
        onPressed: _togglePasswordVisibility,
      ),
      validator: (v) => (v == null || v.isEmpty)
          ? 'Please enter your password'
          : null,
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.2),
            borderRadius: BorderRadius.circular(10.0),
          ),
          height: 60.0,
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(icon, color: Colors.white),
              suffixIcon: suffix,
              hintText: 'Enter your $label',
              hintStyle: const TextStyle(color: Colors.white70),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: const Text('Forgot Password?',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : _login,
        style: ElevatedButton.styleFrom(
          elevation: 5.0,
          padding: const EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          backgroundColor: Colors.white,
        ),
        child: _loading
            ? const CircularProgressIndicator(color: Color(0xFF6A040F))
            : const Text(
                'LOGIN',
                style: TextStyle(
                  color: Color(0xFF6A040F),
                  letterSpacing: 1.5,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }


  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const SignupPage())),
      child: RichText(
        text: const TextSpan(children: [
          TextSpan(
              text: "Don't have an Account? ",
              style: TextStyle(color: Colors.white, fontSize: 18.0)),
          TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
