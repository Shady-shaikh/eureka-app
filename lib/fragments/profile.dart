// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, unused_local_variable, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:eureka/util/constants.dart' as constants;

class StudentProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user_info =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: constants.mainColor,
        title: Text('Student Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context)
                .pop(); // This pops the current route and returns to the previous page.
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              // decoration: BoxDecoration(
              //     gradient: LinearGradient(colors: [
              //   constants.mainColor,
              //   Color.fromARGB(255, 249, 182, 252),
              // ]))
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/drawer_bg.jpg'),
                  opacity: 0.4,
                  fit: BoxFit.cover,
                ),
                // gradient: LinearGradient(
                //   colors: [
                //     constants.mainColor, // Your main color
                //     Color.fromARGB(255, 249, 182, 252), // White color
                //   ],
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                // ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black, // Set the border color
                            width: 1.5, // Set the border width
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 60.0,
                          backgroundColor: constants
                              .mainColor, // Background color for the avatar
                          child: ClipOval(
                            child: Image.network(
                                '${constants.project_url}/backend/web/uploads/profilepic/${user_info['profile_pic']}',
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stacktrace) {
                              return Image.asset(
                                'assets/pro.png',
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.cover,
                              );
                            }),
                          ),
                        ),
                      ),

                      SizedBox(height: 10.0),
                      Text(
                        user_info['name'] + ' ' + user_info['surname'],
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      // Text('Course: Your Course Name'),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email'),
              subtitle:
                  Text(user_info['email']), // Replace with the student's email
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone'),
              subtitle: Text(user_info[
                  'contact_no']), // Replace with the student's phone number
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Address'),
              subtitle: Text(
                  user_info['address']), // Replace with the student's address
            ),
            ListTile(
              leading: Icon(Icons.cake),
              title: Text('Birthdate'),
              subtitle: Text(
                  user_info['dob']), // Replace with the student's birthdate
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Father's Name"),
              subtitle: Text(user_info[
                  'fathername']), // Replace with the student's father's name
            ),
            ListTile(
              leading: Icon(
                Icons.woman,
              ),
              title: Text("Mother's Name"),
              subtitle: Text(user_info[
                  'mothername']), // Replace with the student's mother's name
            ),
          ],
        ),
      ),
    );
  }
}
