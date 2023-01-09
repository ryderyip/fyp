import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/user_entities.dart';
import 'package:flutter_application_1/services/fetch_user_service.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'create_account_pages.dart';

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({super.key, required this.title});

  final String title;

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  static const _pageSize = 20;
  static const _firstPageKey = 1;

  final PagingController<int, Student> _studentPagingController = PagingController(firstPageKey: _firstPageKey);
  final PagingController<int, Teacher> _teacherPagingController = PagingController(firstPageKey: _firstPageKey);
  final PagingController<int, Admin> _adminPagingController = PagingController(firstPageKey: _firstPageKey);

  @override
  void initState() {
    _studentPagingController.addPageRequestListener((pageKey) => _fetchPage<Student>(pageKey, _studentPagingController));
    _teacherPagingController.addPageRequestListener((pageKey) => _fetchPage<Teacher>(pageKey, _teacherPagingController));
    _adminPagingController.addPageRequestListener((pageKey) => _fetchPage<Admin>(pageKey, _adminPagingController));
    super.initState();
  }

  Future<void> _fetchPage<T extends User>(int pageKey, PagingController<int, T> pagingController) async {
    final newItems = List<T>.from(await FetchUserService(page: pageKey, pageSize: _pageSize).fetch<T>());
    final isLastPage = newItems.length < _pageSize;
    if (isLastPage) {
      pagingController.appendLastPage(newItems);
    } else {
      final nextPageKey = pageKey + 1;
      pagingController.appendPage(newItems, nextPageKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Builder(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Account Management'),
            bottom: const TabBar(tabs: <Widget>[
              Tab(text: 'Students'),
              Tab(text: 'Teachers'),
              Tab(text: 'Admins'),
            ]),
          ),
          body: TabBarView(
            children: <Widget>[
              buildCustomScrollView(_studentPagingController),
              buildCustomScrollView(_teacherPagingController),
              buildCustomScrollView(_adminPagingController),
            ],
          ),
        );
      }) 
    );
  }

  Widget buildCustomScrollView<T extends User>(PagingController<int, T> pagingController) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AccountCreatePage<T>()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      body: CustomScrollView(
          slivers: [
            PagedSliverList<int, T>(
              pagingController: pagingController,
              builderDelegate: PagedChildBuilderDelegate<T>(itemBuilder: (context, item, index) {
                var userInfo = item.commonInformation;
                return Card(
                    elevation: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                            child: ListTile(
                              title: Text('${userInfo.name} (tel.${userInfo.phone})'),
                              subtitle: Text(userInfo.email),
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.info),
                              tooltip: 'View Details',
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ],
                    ));
              }),
            )
          ]),
    );
  }

  @override
  void dispose() {
    _studentPagingController.dispose();
    _teacherPagingController.dispose();
    _adminPagingController.dispose();
    super.dispose();
  }
}
