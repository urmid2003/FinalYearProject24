
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reusable_widget.dart';
import 'home_screen.dart';
import 'color_utils.dart';
import 'package:flutter/material.dart';
import 'signin_screen.dart';
import 'custom_scaffold.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();

  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                // get started form
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // get started text
                      const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: Color.fromARGB(255, 20, 148, 43),
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      // full name
                      TextFormField(
                        controller: _userNameTextController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Full name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Full Name'),
                          hintText: 'Enter Full Name',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // email
                      TextFormField(
                        controller: _emailTextController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          if (!value.contains('@') ||
                              value.toUpperCase() == value) {
                            return 'Please enter a valid email address';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  if (!value.contains('.com') && !value.contains('.in') && !value.contains('.edu')) {
    return 'Email domain must be .com, .in, or .edu';
  }
                          return null;
                        },
                        
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // password
                      TextFormField(
                        controller: _passwordTextController,
                        obscureText: _obscureText,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            icon: Icon(_obscureText
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 25.0,
                      ),
                      // i agree to the processing
                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (bool? value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                            activeColor: const Color.fromARGB(255, 20, 148, 43),
                          ),
                          const Text(
                            'I agree to the processing of ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          const Text(
                            'Personal data',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 20, 148, 43),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // signup button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formSignupKey.currentState!.validate() &&
                                agreePersonalData) {
                              try {
                                UserCredential userCredential =
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                  email: _emailTextController.text,
                                  password: _passwordTextController.text,
                                );
                                // Set display name
                                FirebaseAuth.instance.currentUser!
                                    .updateProfile(
                                        displayName:
                                            _userNameTextController.text);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignInScreen()));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'The email address is already in use by another account')),
                                );
                              }
                            } else if (!agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please agree to the processing of personal data')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 20, 148, 43),
                          ),
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                                color: Colors.white), // Set text color to white
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      // sign up divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 25.0,
                      ),
                      // already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 20, 148, 43),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}