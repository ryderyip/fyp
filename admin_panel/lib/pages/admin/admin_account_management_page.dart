import 'package:admin_panel/pages/admin/user_detail_page.dart';
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
  String? _searchbarText;

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
    final newItems = List<T>.from(await FetchUserService(page: pageKey, pageSize: _pageSize, search: _searchbarText).fetch<T>());
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
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    buildCustomScrollView(_studentPagingController),
                    buildCustomScrollView(_teacherPagingController),
                    buildCustomScrollView(_adminPagingController),
                  ],
                ),
              )
            ],
          ),
        );
      }) 
    );
  }

  Widget buildCustomScrollView<T extends User>(PagingController<int, T> pagingController) {
    TextEditingController controller = TextEditingController();
    void updateSearchTerm(String searchTerm) {
      _searchbarText = searchTerm;
      pagingController.refresh();
    }

    void clearSearch() {
      if (controller.value.text != '') {
        updateSearchTerm('');
        controller.clear();
      }
    }
    
    void enterDetailPage({required User user}) {
      Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => UserDetailsPage(
              user: user,
              usertype: UserType.fromType(user.runtimeType)))
      );
    }
    
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: TextField(
                  controller: controller,
                  decoration:  InputDecoration(
                      filled: true,
                      fillColor: Colors.white38,
                      hintText: 'Search by name/email/phone/username', 
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    suffixIcon: IconButton(
                    onPressed: clearSearch,
                    icon: const Icon(Icons.clear),
                  ),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: updateSearchTerm,
                ),
              ),
            ),
            PagedSliverList<int, T>(
              pagingController: pagingController,
              builderDelegate: PagedChildBuilderDelegate<T>(itemBuilder: (context, user, index) {
                var userInfo = user.commonInformation;
                return Card(
                    elevation: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                            child: ListTile(
                              title: Text('${userInfo.name} (tel.${userInfo.phone})'),
                              subtitle: Text(userInfo.email),
                              onTap: () => enterDetailPage(user: user),
                            )
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

class CharacterSearchInputSliver extends SliverToBoxAdapter {
  late TextField _field;
  
  CharacterSearchInputSliver({super.key, void Function(String)? onChanged}) {
    _field = TextField(onChanged: onChanged);
  }
}