import 'package:fitnessapp_idata2503/components/navigation_bar.dart';
import 'package:fitnessapp_idata2503/main.dart';
import 'package:fitnessapp_idata2503/pages/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/styles.dart';

class EditFieldPage extends StatelessWidget {
  final String title;
  final String initialValue;
  final ValueChanged<String> onSave;
  final TextInputType keyboardType;

  EditFieldPage({
    required this.title,
    required this.initialValue,
    required this.onSave,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = initialValue;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back,
              color: AppColors.fitnessMainColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.fitnessBackgroundColor,
      ),
      body: Container(
        color: AppColors.fitnessBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                cursorColor: Colors.white,
                controller: _controller,
                keyboardType: keyboardType,
                decoration: const InputDecoration(
                  hintStyle: TextStyle(color: Colors.white),
                  labelStyle: TextStyle(fontSize: 20, color: Colors.white),
                  suffixStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fitnessMainColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fitnessMainColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  style: const ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(AppColors.fitnessModuleColor),
                    foregroundColor:
                        WidgetStatePropertyAll(AppColors.fitnessModuleColor),
                  ),
                  onPressed: () {
                    onSave(_controller.text);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
