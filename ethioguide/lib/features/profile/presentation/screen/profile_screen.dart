import 'package:ethioguide/core/components/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ethioguide/core/config/app_color.dart';
import 'package:ethioguide/features/authentication/domain/entities/user.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'package:intl/intl.dart'; // A package for formatting dates

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
     context.read<ProfileBloc>().add(FetchProfileData());
    
    // It directly returns the view.
    return const ProfileView();
    
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  final int pageIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Profile',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Manage your account information',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onSelected: (value) {
              if (value == 'logout') {
                // Dispatch the logout event when the user selects 'Logout'
                context.read<ProfileBloc>().add(LogoutTapped());
              }
              if (value == 'change_password') {
      // Use pushNamed to navigate to the child route
      context.pushNamed('change_password');
    }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
               const PopupMenuItem<String>(
      value: 'change_password',
      child: Text('Change Password'),
    ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          // Listen for the loggedOut state to navigate the user away
          if (state.status == ProfileStatus.loggedOut) {
            // Use `go` to clear the navigation stack and send the user to the auth screen
            context.go('/auth');
          }
          
          if (state.status == ProfileStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ProfileStatus.success && state.user != null) {
            // Pass the user data to our helper widgets
            return _ProfileContent(user: state.user!);
          }
          // Show an empty state or an error message if the user is null
          return const Center(child: Text('Could not load profile.'));
        },
      ),
      bottomNavigationBar: bottomNav(
        context: context,
        selectedIndex: pageIndex,
      ),
    );
  }
}

// --- HELPER WIDGETS to keep the build method clean ---

class _ProfileContent extends StatelessWidget {
  final User user;
  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _ProfileHeaderCard(user: user),
        const SizedBox(height: 24),
        _PersonalInfoCard(user: user),
      ],
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final User user;
  const _ProfileHeaderCard({required this.user});

  @override
  Widget build(BuildContext context) {
    // Use a date formatter to make the date look nice
    final memberSince = user.createdAt != null
        ? DateFormat('M/d/yyyy').format(user.createdAt!)
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.darkGreenColor,
                // Display the user's initials as a fallback
                child: Text(
                  user.initials,
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
                // TODO: Add logic to show user.profilePicture if it's not null
              ),
              Positioned(
                bottom: -5,
                right: -5,
                child: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      /* TODO: Implement image picker */
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Member since $memberSince',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoCard extends StatefulWidget {
  final User user;
  const _PersonalInfoCard({required this.user});

  @override
  State<_PersonalInfoCard> createState() => _PersonalInfoCardState();
}

class _PersonalInfoCardState extends State<_PersonalInfoCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _usernameController = TextEditingController(text: widget.user.username ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final bool isEditing = state.isEditing;

        if (state.status == ProfileStatus.success) {
          _nameController.text = state.user?.name ?? '';
          _emailController.text = state.user?.email ?? '';
          _usernameController.text = state.user?.username ?? '';
        }

        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  isEditing
                      ? Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                              onPressed: () {
                                context.read<ProfileBloc>().add(EditModeCancelled());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.save_alt_outlined, color: Colors.green),
                              onPressed: () {
                                context.read<ProfileBloc>().add(ProfileSaveChanges(
                                  name: _nameController.text,
                                  email: _emailController.text,
                                  username: _usernameController.text,
                                ));
                              },
                            ),
                          ],
                        )
                      : IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.darkGreenColor),
                          onPressed: () {
                            context.read<ProfileBloc>().add(EditModeToggled());
                          },
                        ),
                ],

              ),
              const SizedBox(height: 16),
              _EditableInfoRow(label: 'Full Name', controller: _nameController, isEditing: isEditing),
              const Divider(height: 32),
              _EditableInfoRow(label: 'Email Address', controller: _emailController, isEditing: isEditing),
              const Divider(height: 32),
              _EditableInfoRow(label: 'Username', controller: _usernameController, isEditing: isEditing),
            ],
          ),

        );
      },

    );
  }
}

class _EditableInfoRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEditing;

  const _EditableInfoRow({
    required this.label,
    required this.controller,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),

        isEditing
            ? TextFormField(
                controller: controller,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(isDense: true, border: InputBorder.none),
              )
            : Text(
                controller.text,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

      ],
    );
  }
}
