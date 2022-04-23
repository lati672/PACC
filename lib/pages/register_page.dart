// Packages
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';

// Services
import '../services/media_service.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';

// Widgets
import '../widgets/custom_input_fields.dart';
import 'package:chatifyapp/widgets/rounded_image_network.dart';
import '../widgets/rounded_button.dart';

// Providers
import '../providers/authentication_provider.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
// * Responsive layout
  late double _deviceWidth;
  late double _deviceHeight;

  //* Store reference Provider
  late AuthenticationProvider _auth;

  //* Store database reference Provider
  late DatabaseService _database;

  //* Store cloud storage reference
  late CloudStorageService _cloudStorageService;

  // * Store reference to the navigation service

// *Variables to store each Form field input values (texts)
  String? _name;
  String? _email;
  String? _password;
  String? _role;
  bool value = true;

// * Variable responsible for holding/store our image
  PlatformFile? _profileImage;

// Form key
  final _registerFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // * The auth provider will work because we wrapped our mainApp with MultiProvider
    _auth = Provider.of<AuthenticationProvider>(context);
    _database = GetIt.instance.get<DatabaseService>();
    _cloudStorageService = GetIt.instance.get<CloudStorageService>();
    // * Responsive device
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    value = true;
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Container(
            width: _deviceWidth,
            height: _deviceHeight,
            padding: EdgeInsets.symmetric(horizontal: _deviceWidth * .02),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _profileImageField(),
                SizedBox(
                  height: _deviceHeight * .05,
                ),
                SizedBox(
                  height: _deviceHeight * .42,
                  child: _registerForm(),
                ),
                SizedBox(
                  height: _deviceHeight * .05,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: _deviceWidth * 0.4,
                        child: buildStudentCheckbox(),
                      ),
                      SizedBox(
                        width: _deviceWidth * 0.4,
                        child: buildParentCheckbox(),
                      ),
                    ]),
                SizedBox(
                  height: _deviceHeight * .05,
                ),
                _registerButton(),
              ],
            ),
          ),
        ));
  }

  // *Upload image
  Widget _profileImageField() {
    return GestureDetector(
      onTap: () =>
          GetIt.instance.get<MediaService>().pickImageFromLibrary().then(
        (_file) {
          if (_file != null) {
            setState(
              () {
                _profileImage = _file;
              },
            );
          }
        },
      ),
      child: () {
        if (_profileImage != null) {
          // Selected image
          return RoundedImageFile(
            key: UniqueKey(),
            image: _profileImage!,
            size: _deviceHeight * .15,
          );
        } else {
          // Default Image
          return RoundedAssetImage(
            key: UniqueKey(),
            image: 'assets/images/default-image.jpg',
            size: _deviceHeight * .15,
          );
        }
      }(),
    );
  }

  Widget _registerForm() {
    return Container(
      constraints: BoxConstraints(maxHeight: _deviceHeight * 0.45),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: _deviceHeight * 0.02),
              height: _deviceHeight * 0.1,
              width: _deviceWidth * .80,
              child: CustomTextFormField(
                onSaved: (_value) {
                  setState(() {
                    _name = _value;
                  });
                },
                regularExpression: r'.{2}',
                hintText: '用户名，长度需大于2位',
                obscureText: false,
              ),
            ),
            // *Name
            // *Email Field
            Container(
                margin: EdgeInsets.symmetric(vertical: _deviceHeight * 0.02),
                height: _deviceHeight * 0.1,
                width: _deviceWidth * .80,
                child: CustomTextFormField(
                  onSaved: (_value) {
                    setState(() {
                      _email = _value;
                    });
                  },
                  regularExpression:
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  hintText: '邮箱',
                  obscureText: false,
                )),
            // TODO: Add Hide/Show Password toggle
            // *Password Field
            Container(
              margin: EdgeInsets.symmetric(vertical: _deviceHeight * 0.02),
              width: _deviceWidth * .80,
              height: _deviceHeight * 0.1,
              child: CustomTextFormField(
                onSaved: (_value) {
                  setState(() {
                    _password = _value;
                  });
                },
                regularExpression: r".{8,}", //Password longer than 8 char
                hintText: '密码长度需大于等于8位',
                obscureText: true,
              ),
            )
          ],
        ),
      ),
    );
  }

  bool isChecked = true;

  Widget buildStudentCheckbox() => ListTile(
        leading: Checkbox(
          value: isChecked,
          onChanged: (value) {
            setState(() {
              isChecked = value!;
            });
          },
        ),
        title: const Text(
          '学生',
          style: TextStyle(color: Colors.black),
        ),
      );

  Widget buildParentCheckbox() => ListTile(
        leading: Checkbox(
          value: !isChecked,
          onChanged: (value) {
            setState(() {
              isChecked = !value!;
            });
          },
        ),
        title: const Text(
          '家长',
          style: TextStyle(color: Colors.black),
        ),
      );

// TODO: Futuramente, mudar o nome de Register => Sign up e colocar texto Sign up em bold
  Widget _registerButton() {
    return RoundedButton(
      name: '注册',
      width: _deviceWidth * .65,
      height: _deviceHeight * .075,
      onPress: () async {
        if (_registerFormKey.currentState!.validate()) {
          //* Saving the input
          _registerFormKey.currentState!.save();
          //* Register user in the Firebase Authentication
          final _uid = await _auth.registerUserUsingEmailAndPassword(
            _email!,
            _password!,
          );
          //* Upload the user image to the Firebase Storage
          final String? _imageUrl;
          if (_profileImage != null) {
            _imageUrl =
                await _cloudStorageService.saveUserImageProfileToStorage(
              _uid!,
              _profileImage!,
            );
          } else {
            _imageUrl = await _cloudStorageService
                .saveDefaultUserImageProfileToStorage(_uid!);
          }
          // Go to database to create user with uid
          await _database.createUser(
            _uid,
            _email!,
            _name!,
            _imageUrl!,
            isChecked ? 'Student' : 'Parent',
          );
          //* Once the user is created, we will go back to the login page where we can login with the registered credentials
          await _auth.logout();
          // * requires the login with the user previously created
          await _auth.loginUsingEmailAndPassword(
            _email!,
            _password!,
          );
        }
      },
    );
  }
}
