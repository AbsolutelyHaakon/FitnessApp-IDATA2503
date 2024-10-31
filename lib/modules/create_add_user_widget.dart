import 'package:fitnessapp_idata2503/database/tables/user.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/pages/me.dart';

class CreateAddUserWidget extends StatefulWidget {
  final LocalUser? user;
  final ValueChanged<Map<String, String>> onSubmit;

  const CreateAddUserWidget({
    Key? key,
    this.user,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<CreateAddUserWidget> createState() => _CreateAddUserWidgetState();
}

class _CreateAddUserWidgetState extends State<CreateAddUserWidget> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final weightController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.user?.name ?? '';
    emailController.text = widget.user?.email ?? '';
    passwordController.text = widget.user?.password ?? '';
    weightController.text = widget.user?.weight?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit User' : 'Add User'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              autofocus: true,
              controller: nameController,
              decoration: const InputDecoration(hintText: 'User name'),
              validator: (value) => value!.trim().isEmpty ? 'Please enter a user name' : null,
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(hintText: 'Email'),
              validator: (value) => value!.trim().isEmpty ? 'Please enter an email' : null,
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(hintText: 'Password'),
              validator: (value) => value!.trim().isEmpty ? 'Please enter a password' : null,
            ),
            TextFormField(
              controller: weightController,
              decoration: const InputDecoration(hintText: 'Weight'),
              validator: (value) => value!.trim().isEmpty ? 'Please enter a weight' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              widget.onSubmit({
                'name': nameController.text,
                'email': emailController.text,
                'password': passwordController.text,
                'weight': weightController.text,
              });
              Navigator.pop(context);
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}