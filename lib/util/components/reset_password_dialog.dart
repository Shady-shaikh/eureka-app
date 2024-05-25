import 'package:flutter/material.dart';
import 'package:eureka/global_helper.dart';
import 'package:eureka/util/constants.dart' as constants;

class ResetPasswordDialog extends StatefulWidget {
  @override
  _ResetPasswordDialogState createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  GlobalHelper globalHelper = GlobalHelper();
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Forgot Password',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            buildTextField(
              controller: emailController,
              labelText: 'Email',
              suffixIcon: Icons.email,
            ),
            SizedBox(height: 10),
            SizedBox(height: 10),
            buildPasswordTextField(
              controller: newPasswordController,
              labelText: 'New Password',
              obscureText: _obscureNewPassword,
              onPressed: () => toggleObscure('_obscureNewPassword'),
            ),
            SizedBox(height: 10),
            buildPasswordTextField(
              controller: confirmPasswordController,
              labelText: 'Confirm Password',
              obscureText: _obscureConfirmPassword,
              onPressed: () => toggleObscure('_obscureConfirmPassword'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (fieldsNotEmpty()) {
                  showLoader();
                  var resetPassword = await globalHelper.updatePassword(
                    emailController.text,
                    confirmPasswordController.text,
                  );

                  resetPassword['success'] != null
                      ? constants.Notification(resetPassword['success'])
                      : constants.Notification(resetPassword['error']);

                  hideLoader();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
      ),
    );
  }

  Widget buildPasswordTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = true,
    required VoidCallback onPressed,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: onPressed,
        ),
      ),
    );
  }

  void toggleObscure(String variableName) {
    setState(() {
      switch (variableName) {
        case '_obscureOldPassword':
          _obscureOldPassword = !_obscureOldPassword;
          break;
        case '_obscureNewPassword':
          _obscureNewPassword = !_obscureNewPassword;
          break;
        case '_obscureConfirmPassword':
          _obscureConfirmPassword = !_obscureConfirmPassword;
          break;
      }
    });
  }

  bool fieldsNotEmpty() {
    return emailController.text.isNotEmpty &&
        newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;
  }

  void showLoader() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void hideLoader() {
    Navigator.pop(context);
  }
}
