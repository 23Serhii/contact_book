import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:email_validator/email_validator.dart';

import '../helpers/contact_helper.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;

  const ContactPage({Key? key, this.contact}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();

  bool _userEdited = false;

  Contact? _editedContact;
  bool _isEmailCorrect = true;

  Future<void> showWarningDialog(BuildContext context, String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Неправильно введений формат"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact!.toMap());

      _nameController.text = _editedContact!.name as String;
      _emailController.text = _editedContact!.email as String;
      _phoneController.text = _editedContact!.phone as String;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text(_editedContact!.name ?? "Новий контакт"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact!.name != null &&
                _editedContact!.name!.isNotEmpty &&
                _editedContact!.email != null &&
                _editedContact!.name!.isNotEmpty &&
                _editedContact!.phone != null &&
                _editedContact!.phone!.isNotEmpty &&
                !_isEmailCorrect) {
              Navigator.pop(context, _editedContact);
            } else {
              showWarningDialog(context,
                  "Будь ласка, перевірте правильність введення даних.");
            }
            ;
          },
          child: const Icon(Icons.save),
          backgroundColor: Colors.blueAccent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(children: [
            GestureDetector(
              child: Container(
                width: 140.0,
                height: 140.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: _editedContact!.img != null
                          ? FileImage(File(_editedContact!.img!))
                          : const AssetImage('images/person.png')
                              as ImageProvider,
                      fit: BoxFit.cover),
                ),
              ),
              onTap: () {
                _showPhotoSourceOptions(context,
                    _editedContact); // ignore: invalid_use_of_visible_for_testing_member
              },
            ),
            TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              decoration: const InputDecoration(labelText: "Ім'я"),
              onChanged: (text) {
                _userEdited = true;
                setState(() {
                  _editedContact!.name = text;
                });
              },
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Пошта"),
              focusNode: _emailFocus,
              onChanged: (text) {
                _editedContact!.email = text;
                _isEmailCorrect = false;
                _userEdited = true;

                bool isValid = EmailValidator.validate(text);
                if (!isValid) {
                  _isEmailCorrect = true;
                  _userEdited = false;
                }
                ;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              decoration: const InputDecoration(labelText: "Номер телефону"),
              onChanged: (text) {
                _userEdited = true;
                _editedContact!.phone = text;
              },
              keyboardType: TextInputType.phone,
            )
          ]),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Виключити зміни?'),
            content: const Text('Якщо ви підете, зміни будуть втрачені.'),
            actions: [
              TextButton(
                child: const Text('Ні'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Так'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  void _showPhotoSourceOptions(BuildContext context, Contact? _editedContact) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextButton(
                        child: const Text(
                          'Камера',
                          style: TextStyle(
                              color: Colors.blueAccent, fontSize: 20.0),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          // ignore: invalid_use_of_visible_for_testing_member
                          ImagePicker.platform
                              .pickImage(
                                  source: ImageSource
                                      .camera) //preferredCameraDevice: CameraDevice.front
                              .then((file) {
                            if (file == null) return;
                            setState(() {
                              _editedContact!.img = file.path;
                            });
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextButton(
                        child: const Text(
                          'Галерея',
                          style: TextStyle(
                              color: Colors.blueAccent, fontSize: 20.0),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          // ignore: invalid_use_of_visible_for_testing_member
                          ImagePicker.platform
                              .pickImage(source: ImageSource.gallery)
                              .then((file) {
                            if (file == null) return;
                            setState(() {
                              _editedContact!.img = file.path;
                            });
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }
}
