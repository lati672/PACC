// Packages
import 'package:chatifyapp/pages/addfriends.dart';
import 'package:chatifyapp/pages/todolist_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

// Providers
import '../providers/authentication_provider.dart';
import '../providers/todolist_provider.dart';

// Services
import '../services/navigation_service.dart';

// Widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';

// Models
import '../models/todo_list_model.dart';

class ParentTodolistPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const ParentTodolistPage({Key? key, required this.cameras}) : super(key: key);

  @override
  _ParentTodolistPageState createState() => _ParentTodolistPageState();
}

class _ParentTodolistPageState extends State<ParentTodolistPage> {
  // Required variables
  late double _deviceWidth;
  late double _deviceHeight;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late TodoListPageProvider _pageProvider;

  @override
  Widget build(BuildContext context) {
    // Responsive layout
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;

    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TodoListPageProvider>(
          create: (_) => TodoListPageProvider(_auth),
        )
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (_context) {
        //* Triggers the info in the widgets to render themselves
        _pageProvider = _context.watch<TodoListPageProvider>();
        return Scaffold(
            body: SafeArea(
                child: Container(
          width: _deviceWidth,
          height: _deviceHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const TopBar('待办'),
              _todosList(),
            ],
          ),
        )));
      },
    );
  }

  // Build UI
  Widget _todosList() {
    List<String>? _students = _pageProvider.students;
    List<String>? _studentsName = _pageProvider.studentsName;
    List<int>? _studentsTodo = _pageProvider.studentsTodo;
    return Expanded(
      child: (() {
        if (_students != null &&
            _studentsName != null &&
            _studentsTodo != null) {
          if (_students.isNotEmpty) {
            return ListView.builder(
              itemCount: _students.length,
              itemBuilder: (BuildContext _context, int _index) {
                return Column(children: [
                  CustomListViewTileWithActivity(
                    height: _deviceHeight * .10,
                    title: _studentsName[_index],
                    subtitle: _studentsTodo[_index].toString() + "条待办",
                    imagePath: 'assets/images/default-image.jpg',
                    isActive: true,
                    isActivity: true,
                    onTap: () =>
                        // _navigation.navigateToPage(TodoListPage(todo: _todos)),
                        _navigation.navigateToPage(
                            TodoListPage(cameras: widget.cameras)),
                  ),
                  Divider(
                    indent: _deviceWidth * .03,
                    endIndent: _deviceWidth * .03,
                    height: 0.2,
                    color: Colors.black12,
                  )
                ]);
              },
            );
          } else {
            return const Center(
              child: Text(
                '未连接到学生',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      })(),
    );
  }
}
