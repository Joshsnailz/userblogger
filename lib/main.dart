import 'dart:js';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:userblogger/firebase_options.dart';
import 'package:userblogger/views/login_view.dart';
import 'package:userblogger/views/register_view.dart';
import 'package:userblogger/views/verify_email_view.dart';
import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'User logger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
        '/verify/': (context) => const VerifyEmailView(), 
      },
    ),);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
          future: Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
                  ),
          builder: (context, snapshot) {
            switch(snapshot.connectionState){
              case ConnectionState.done:
                 final user = FirebaseAuth.instance.currentUser;
                 if(user != null){
                    if(user.emailVerified){
                      return const BlogsView();
                    }else{
                      return const VerifyEmailView();
                    }
                 }else{
                    return const LoginView();
                 }
                
              default: 
                return const CircularProgressIndicator();
            }
            
          },
          
        );
  }
}

enum MenuAction {logout}

class BlogsView extends StatefulWidget {
  const BlogsView({super.key});

  @override
  State<BlogsView> createState() => _BlogsViewState();
}

class _BlogsViewState extends State<BlogsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Blogs'),
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<MenuAction>( 
            onSelected: (value) async {
            switch (value){
              case MenuAction.logout:
                final shouldLogout = await showLogoutDialog(context);
                if (shouldLogout){
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil('/login/', (_) => false,);
                }
            }
          }, itemBuilder:(context) {
            return [
              const PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child:  Text('Logout'),
              ),
            ];
          },)
        ],
      ),
      body: const Text('Userblogger'),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context){
  return showDialog<bool>(context: context, builder: (context) {
    return AlertDialog(
      title: const Text('Sig Out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(onPressed: () {
          Navigator.of(context).pop(false);
        } , child: const Text('Cancel')),
        TextButton(onPressed: () {
          Navigator.of(context).pop(true);
        } , child: const Text('Logout')),
      ],
    );
  },).then((value) => value ?? false);
}