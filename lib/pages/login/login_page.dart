// Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

// Widgets
import 'package:PACCPolicyapp/widgets/custom_input_fields.dart';
import 'package:PACCPolicyapp/widgets/rounded_button.dart';

// Providers
import 'package:PACCPolicyapp/providers/authentication_provider.dart';

// Services
import 'package:PACCPolicyapp/services/navigation_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Responsive UI for diferent devices
  late double _deviceWidth;
  late double _deviceHeight;
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  late AuthenticationProvider _auth;
  late NavigationService _navigationService;

  final _loginFormKey = GlobalKey<FormState>();

  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigationService = GetIt.instance.get<NavigationService>();
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: _buildUI());
  }

  Widget _buildUI() {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * .03,
            vertical: _deviceHeight * .02,
          ),
          width: _deviceWidth * .97,
          height: _deviceHeight * .98,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/background_tree.jpg"),
                fit: BoxFit.cover),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _pageTitle(),
              SizedBox(
                height: _deviceHeight * .04,
              ),
              _loginForm(),
              SizedBox(
                height: _deviceHeight * .05,
              ),
              _loginButton(),
              SizedBox(
                height: _deviceHeight * .02,
              ),
              _registerAccountLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: Container(
          //用来放置app图标
          height: _deviceHeight * .10,
        )),
        const Expanded(
            child: Text(
          'PACC Policy app',
          style: TextStyle(
              color: Colors.black, fontSize: 30, fontWeight: FontWeight.w400),
        ))
      ],
    );
  }

  Widget _loginForm() {
    return SizedBox(
      height: _deviceHeight * .25,
      width: _deviceWidth * .80,
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Email Field
            CustomTextFormField(
              onSaved: (_value) {
                setState(() {
                  _email = _value;
                });
              },
              regularExpression:
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
              hintText: 'email',
              obscureText: false,
            ),
            // Password Field
            CustomTextFormField(
              onSaved: (_value) {
                setState(() {
                  _password = _value;
                });
              },
              // Password longer than 8 chars
              regularExpression: r".{8,}",
              hintText: 'password',
              obscureText: true,
            )
          ],
        ),
      ),
    );
  }

  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.black54,
                  children: <Widget>[
                    Center(
                      child: Column(children: const [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait....",
                          style: TextStyle(color: Colors.blueAccent),
                        )
                      ]),
                    )
                  ]));
        });
  }

  Widget _loginButton() {
    return RoundedButton(
      name: 'Login',
      width: _deviceWidth * .65,
      height: _deviceHeight * .075,
      onPress: () {
        if (_loginFormKey.currentState!.validate()) {
          _loginFormKey.currentState!.save();
          showLoadingDialog(context, _keyLoader);
          _auth.loginUsingEmailAndPassword(_email!, _password!);
        }
      },
    );
  }

  Widget _registerAccountLink() {
    return RoundedButton(
      name: 'Create new account',
      width: _deviceWidth * .65,
      height: _deviceHeight * .075,
      onPress: () {
        _navigationService.nagivateRoute('/register');
      },
    );
  }
}
