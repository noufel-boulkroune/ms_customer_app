import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ms_customer_app/widgets/appbar_widget.dart';
import 'package:ms_customer_app/widgets/auth_widgets.dart';
import 'package:ms_customer_app/widgets/blue_button.dart';

class ForgotPassword extends StatefulWidget {
  static const routeName = "forgot-password";
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: AppBarBackButton(color: Colors.black),
        title: const AppBarTitle(title: "Forgot Password?"),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "To reset your passeord \n\n pleas enter your email address and click on the button below",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              TextFormField(
                controller: emailController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Pleas enter your email";
                  } else if (!value.isValidEmail()) {
                    return "Invalid email";
                  } else if (value.isValidEmail()) {}
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: textFormDecoration.copyWith(
                  labelText: "Email Address",
                  hintText: "Enter your email",
                ),
              ),
              const SizedBox(
                height: 120,
              ),
              BlueButton(
                  lable: "Send Reset Password Link",
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: emailController.text);
                      } catch (error) {
                        print(error);
                      }
                    } else {
                      print("form not valid");
                    }
                  },
                  width: .8,
                  color: Colors.lightBlueAccent)
            ],
          ),
        ),
      ),
    );
  }
}
