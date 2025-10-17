import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mateo_group_activity1/pages/login.dart';

// The Signup Page Widget
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static const String _signupApiUrl = 'http://mateogroup.mywebcommunity.org/signup.php';

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _showSignupSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Signup Successful'),
          content: Text('Welcome, ${_nameController.text}! Your account has been created.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        );
      },
    );
  }

  // Shows an alert for validation errors
  void _showValidationErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Signup Failed'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        );
      },
    );
  }

  void _signup() async{
    if (!_formKey.currentState!.validate()) {
      _showValidationErrorDialog('Please fill all fields correctly.');
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Signing up...')),
    );

    try{
      final response = await http.post(
        Uri.parse(_signupApiUrl),
        headers:{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'name':_nameController.text.trim(),
          'email':_emailController.text.trim(),
          'password':_passwordController.text
        })
      );

      scaffoldMessenger.hideCurrentSnackBar();

      if(response.statusCode == 201){
        _showSignupSuccessDialog();
      }
      else{
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'An unknown error occured.';
        _showValidationErrorDialog(errorMessage);
      }
    }catch(e){
      scaffoldMessenger.hideCurrentSnackBar();
      _showValidationErrorDialog('Network error: Could not connect to the server.');
      print('Signup Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      Color(0xFF8B0000), // Dark Red
                      Color(0xFF6A040F),
                      Color(0xFF5A0208),
                      Color(0xFF4B0000), // Maroon
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              SizedBox(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Roboto',
                            fontSize: 35.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        _buildTextField(controller: _nameController, label: 'Full Name', icon: Icons.person, hint: 'Enter your Full Name'),
                        const SizedBox(height: 20.0),
                        _buildTextField(controller: _emailController, label: 'Email', icon: Icons.email, hint: 'Enter your Email', keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 20.0),
                        _buildPasswordTextField(controller: _passwordController, label: 'Password', obscure: _obscurePassword, toggle: _togglePasswordVisibility),
                        const SizedBox(height: 20.0),
                        _buildPasswordTextField(controller: _confirmPasswordController, label: 'Confirm Password', obscure: _obscureConfirmPassword, toggle: _toggleConfirmPasswordVisibility),
                        const SizedBox(height: 40.0),
                        _buildSignupBtn(),
                        const SizedBox(height: 20.0),
                        _buildLoginBtn(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, required String hint, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.2),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6.0, offset: Offset(0, 2))],
          ),
          height: 60.0,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(icon, color: Colors.white),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white70),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your $label';
              if (label == 'Email' && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTextField({required TextEditingController controller, required String label, required bool obscure, required VoidCallback toggle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.2),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6.0, offset: Offset(0, 2))],
          ),
          height: 60.0,
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(Icons.lock, color: Colors.white),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                onPressed: toggle,
              ),
              hintText: 'Enter your Password',
              hintStyle: const TextStyle(color: Colors.white70),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your password';
              if (label == 'Confirm Password' && value != _passwordController.text) {
                return 'Passwords do not match';
              }
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSignupBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _signup,
        style: ElevatedButton.styleFrom(
          elevation: 5.0,
          padding: const EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          backgroundColor: Colors.white,
        ),
        child: const Text(
          'SIGN UP',
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

  Widget _buildLoginBtn() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Already have an Account? ',
              style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w400),
            ),
            TextSpan(
              text: 'Sign In',
              style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

