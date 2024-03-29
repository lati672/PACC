// Packages
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

// Providers
import 'package:PACCPolicyapp/providers/authentication_provider.dart';

// Services
import 'package:PACCPolicyapp/services/database_service.dart';
import 'package:PACCPolicyapp/services/media_service.dart';
import 'package:PACCPolicyapp/services/cloud_storage_service.dart';
import 'package:PACCPolicyapp/services/navigation_service.dart';

// Pages

// Models
import 'package:PACCPolicyapp/models/chat_user_model.dart';

class UserProfilePage extends StatefulWidget {
  UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late ChatUserModel user;
  late DatabaseService _database;
  late AuthenticationProvider _auth;
  late double _deviceWidth;
  late double _deviceHeight;
  late CloudStorageService _cloudStorageService;
  late CloudStorageService _storage;
  late MediaService _media;
  late NavigationService _navigation;
  PlatformFile? _ChatImage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _storage = GetIt.instance.get<CloudStorageService>();
    _auth = Provider.of<AuthenticationProvider>(context);
    _database = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    user = _auth.user;
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: ListView(
        children: <Widget>[
          SizedBox(height: _deviceHeight * .02),
          HeaderSection(),
          Container(color: Colors.black12, height: 7),
          TextButton(
              onPressed: () {
                _auth.logout();
              },
              child: const Text(
                'Log out',
                style: TextStyle(color: Colors.black, fontSize: 20),
              )),
          Container(color: Colors.black12, height: 7),
        ],
      ),
    ));
  }

  void updateUserProfileImage() async {
    _cloudStorageService = GetIt.instance.get<CloudStorageService>();
    try {
      _ChatImage =
          await GetIt.instance.get<MediaService>().pickImageFromLibrary();
      if (_ChatImage != null) {
        final downloadUrl = await _storage.uploadUserImageProfileToStorage(
            _auth.user.uid, _ChatImage!);
      }
    } catch (error) {
      debugPrint('$error');
    }
  }

  Widget HeaderSection() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
            height: _deviceHeight * .2,
            padding: EdgeInsets.all(_deviceWidth * .02),
            //名片部分，头像、账号、用户名
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => updateUserProfileImage(),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(user.imageUrl),
                    radius: _deviceWidth * 0.1,
                  ),
                ),
                SizedBox(width: _deviceWidth * .05),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: _deviceWidth * .01),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _auth.user.name,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 20),
                      ),
                    ),
                  ],
                ))
              ],
            ),
          ),
          //used as a divider
          Container(color: Colors.black12, height: _deviceHeight * .015),
          Container(
            //用户邮箱
            margin: EdgeInsets.only(
                top: _deviceHeight * .008, bottom: _deviceHeight * .008),
            child: Row(
              children: [
                const Expanded(
                  child: Icon(
                    Icons.mail_outline_outlined,
                    color: Colors.orange,
                  ),
                  flex: 1,
                ),
                const Expanded(
                  child: Text('Email', style: TextStyle(fontSize: 20)),
                  flex: 2,
                ),
                Expanded(
                    child: Text(
                      _auth.user.email,
                      style:
                          const TextStyle(fontSize: 20, color: Colors.black26),
                      textAlign: TextAlign.left,
                    ),
                    flex: 5)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
