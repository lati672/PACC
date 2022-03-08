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
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * .03,
          vertical: _deviceHeight * .02,
        ),
        width: _deviceWidth * .97,
        height: _deviceHeight * .98,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _profileImageField(),
            SizedBox(
              height: _deviceHeight * .05,
            ),
            _registerForm(),
            SizedBox(
              height: _deviceHeight * .05,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              SizedBox(
                width: 150,
                child: buildStudentCheckbox(),
              ),
              SizedBox(
                width: 150,
                child: buildParentCheckbox(),
              ),
            ]),
            SizedBox(
              height: _deviceHeight * .05,
            ),
            _registerButton(),
            SizedBox(
              height: _deviceHeight * .05,
            ),
          ],
        ),
      ),
    );
  }

  // *Upload image
  Widget _profileImageField() {
    return GestureDetector(
      onTap: () =>
          GetIt.instance.get<MediaService>().pickImageFromLibrary().then(
        (_file) {
          setState(
            () {
              _profileImage = _file;
            },
          );
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

          return RoundedImageNetwork(
            key: UniqueKey(),
            size: _deviceHeight * .15,
            //imagePath: '../image/default-profile-icon-24.jpg'
            imagePath:
                'https://icon-library.com/images/default-profile-icon/default-profile-icon-24.jpg', //'http://i.pravatar.cc/1000?img=65',
          );
        }
      }(),
    );
  }

  Widget _registerForm() {
    return SizedBox(
      height: _deviceHeight * .35,
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // *Name
            CustomTextFormField(
              onSaved: (_value) {
                setState(() {
                  _name = _value;
                });
              },
              regularExpression: r'.{8}',
              hintText: '用户名，长度需大于8位',
              obscureText: false,
            ),
            // *Email Field
            CustomTextFormField(
              onSaved: (_value) {
                setState(() {
                  _email = _value;
                });
              },
              regularExpression:
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
              hintText: '邮箱',
              obscureText: false,
            ),
            // TODO: Add Hide/Show Password toggle
            // *Password Field
            CustomTextFormField(
              onSaved: (_value) {
                setState(() {
                  _password = _value;
                });
              },
              regularExpression: r".{8,}", //Password longer than 8 char
              hintText: '密码长度需大于8位',
              obscureText: true,
            ),
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
        title: Text(
          '学生',
          style: TextStyle(color: Colors.white),
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
        title: Text(
          '家长',
          style: TextStyle(color: Colors.white),
        ),
      );
// TODO: Futuramente, mudar o nome de Register => Sign up e colocar texto Sign up em bold
  Widget _registerButton() {
    return RoundedButton(
      name: '注册',
      width: _deviceWidth * .65,
      height: _deviceHeight * .075,
      onPress: () async {
        //print('button clicked');
        if (_registerFormKey.currentState!.validate() &&
            _profileImage != null) {
          //* Saving the input
          _registerFormKey.currentState!.save();
          //* Register user in the Firebase Authentication
          final _uid = await _auth.registerUserUsingEmailAndPassword(
            _email!,
            _password!,
          );
          //print('regist completed');
          //* Upload the user image to the Firebase Storage
          final _imageUrl =
              await _cloudStorageService.saveUserImageProfileToStorage(
            _uid!,
            _profileImage!,
          );
          // Go to database to create user with uid
          //print('image uploaded');
          await _database.createUser(
            _uid,
            _email!,
            _name!,
            _imageUrl!,
            isChecked ? 'Student' : 'Parent',
          );
          //print('user created');
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
