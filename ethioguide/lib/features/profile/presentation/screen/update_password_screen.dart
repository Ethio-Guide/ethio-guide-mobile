import 'package:ethioguide/core/components/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ethioguide/core/components/textfield.dart'; // Using your custom textfield
import 'package:ethioguide/core/utils/validators.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});
  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("New passwords do not match."),
          backgroundColor: Colors.red,
        ));
        return;
      }
      context.read<ProfileBloc>().add(PasswordUpdateSubmitted(
            oldPassword: _oldPasswordController.text,
            newPassword: _newPasswordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Update Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.passwordUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Password updated successfully!"),
              backgroundColor: Colors.green,
            ));
            context.pop(); // Go back to the profile screen
          }
          if (state.status == ProfileStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ));
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Old Password", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      customTextField(
                        controller: _oldPasswordController,
                        hintText: 'Enter your current password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const Text("New Password", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // Use a BlocBuilder to get the current visibility state
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, state) {
                          return customTextField(
                            controller: _newPasswordController,
                            hintText: 'Enter your new password',
                            prefixIcon: Icons.lock_open_outlined,
                            obscureText: !state.isPasswordVisible, 
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                context.read<ProfileBloc>().add(PasswordVisibilityToggled());
                              },
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const Text("Confirm New Password", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, state) {
                          return customTextField(
                            controller: _confirmPasswordController,
                            hintText: 'Confirm your new password',
                            prefixIcon: Icons.lock_open_outlined,
                            obscureText: !state.isPasswordVisible,
                          );
                        },
                      ),

                      const SizedBox(height: 32),
                      
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, state) {
                          return state.status == ProfileStatus.loading
                              ? const Center(child: CircularProgressIndicator())
                              : CustomButton(text: 'Update Password', onTap: _submit);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
