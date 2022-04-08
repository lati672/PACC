// Packages
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

// Providers
import '../providers/authentication_provider.dart';

// Services
import '../services/database_service.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/navigation_service.dart';

// Pages
import 'package:chatifyapp/pages/test.dart';

// Models
import '../models/chat_user_model.dart';

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
                '退出登录',
                style: TextStyle(color: Colors.black, fontSize: 20),
              )),
          TextButton(
              onPressed: () {
                _navigation.navigateToPage(TestPage());
              },
              child: const Text(
                '测试界面',
                style: TextStyle(color: Colors.black, fontSize: 20),
              )),
          Container(color: Colors.black12, height: 7),
          /*
          AnimatedSwitcher(
            duration: Duration(milliseconds: 750),
            transitionBuilder: (Widget child, Animation<double> animation) =>
                SlideTransition(
              child: child,
              position:
                  Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset(0.0, 0.0))
                      .animate(animation),
            ),
            child: HeaderSection(),
          ),*/
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
          // Container(
          //   height: 110,
          //   width: 100,
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(100),
          //     image: DecorationImage(
          //         image: AssetImage(_auth.user.imageUrl), fit: BoxFit.cover),
          //   ),
          // ),
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
                  child: Text('邮箱', style: TextStyle(fontSize: 20)),
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
          Divider(
            indent: _deviceWidth * .05,
            endIndent: _deviceWidth * .05,
            thickness: 0.8,
            height: 1.2,
            color: Colors.black12,
          ),
          Container(
            //用户角色
            margin: EdgeInsets.only(
                top: _deviceHeight * .008, bottom: _deviceHeight * .008),
            child: Row(
              children: [
                const Expanded(
                  child: Icon(
                    Icons.person,
                    color: Colors.green,
                  ),
                  flex: 1,
                ),
                const Expanded(
                  child: Text('权限', style: TextStyle(fontSize: 20)),
                  flex: 2,
                ),
                Expanded(
                    child: Text(
                      _auth.user.role == 'Parent' ? '家长' : '学生',
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
