import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/user_entities.dart';
import 'package:flutter_application_1/services/fetch_user_service.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({super.key, required this.title});

  final String title;

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  Future<List<Student>> _getStudents(int entryPerPage) async {
    return List<Student>.from(await FetchUserService().fetchStudents(entryPerPage));
  }

  @override
  Widget build(BuildContext context) {
    String searchValue = '';
    int _entryPerPage = 5;
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Account Management'),
          bottom: const TabBar(tabs: <Widget>[
            Tab(
              text: 'Students',
            ),
            Tab(
              text: 'Teachers',
            ),
            Tab(
              text: 'Admins',
            ),
          ]),
        ),
        body: TabBarView(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: 57, child: buildFloatingSearchBar()),
                Expanded(
                    child: FutureBuilder(
                  future: _getStudents(_entryPerPage),
                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    return PaginatedDataTable(
                      dataRowHeight: 90,
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Name',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                      ],
                      source: StudentTableSource(snapshot.data),
                      rowsPerPage: _entryPerPage,
                    );
                  },
                )),
              ],
            ),
            Center(
              child: Text("It's rainy here"),
            ),
            Center(
              child: Text("It's sunny here"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 250),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {},
      onSubmitted: (query) {},
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: true,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
        );
      },
    );
  }
}

class StudentTableSource extends DataTableSource {
  List<Student> students;

  StudentTableSource(this.students);

  @override
  DataRow getRow(int index) {
    var studentInfo = students[index].commonInformation;
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Card(
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[ 
              Expanded(child: ListTile(
                title: Text('${studentInfo.name} (tel.${studentInfo.phone})'),
                subtitle: Text(studentInfo.email),
              )),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(onPressed: () {}, icon: const Icon(Icons.info), tooltip: 'View Details',),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ))
      ],
    );
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => students.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}
