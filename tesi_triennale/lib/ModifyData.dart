import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tesi_triennale/Widget/ScrollableWidget.dart';
import 'package:tesi_triennale/model/user.dart';
import 'package:tesi_triennale/utils.dart';

import 'Widget/showTextDialog.dart';
import 'data/users.dart';

class ModifyData extends StatefulWidget{
  const ModifyData({super.key});
  @override
  State<ModifyData> createState() => _ModifyDataState();
}

class _ModifyDataState extends State<ModifyData>{
  late List<User> users;

  @override
  void initState() {
    super.initState();

    this.users = List.of(allUsers);
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: ScrollableWidget(child: buildDataTable()),
  );

  Widget buildDataTable() {
    final columns = ['First Name', 'Last Name', 'Age'];

    return DataTable(
      columns: getColumns(columns),
      rows: getRows(users),
    );
  }

  List<DataColumn> getColumns(List<String> columns){
    return columns.map((String columns) {
      return DataColumn(
          label: Text(columns),
      );
    }).toList();
  }

  List<DataRow> getRows(List<User> users) => users.map((User user){
    final cells = [user.firstName, user.lastName, user.age];
    return DataRow(
      cells: Utils.modelBuilder(cells, (index, cell) {
        final showEditIcon = index  == 0 || index == 1;
        return DataCell(
          Text('$cell'),
          showEditIcon: showEditIcon,
          onTap: (){
            switch(index){
              case 0:
                editFirstName(user);
                break;
              case 1:
                editLastName(user);
                break;
            }
          }
        );
  }),
      );
  }).toList();

  Future editFirstName(User editUser) async {
    final firstName = await showTextDialog(
      context,
      title: 'Modifica nome',
      value: editUser.firstName,
    );

    setState(() => users = users.map((user) {
      final isEditedUser = user == editUser;

      return isEditedUser ? user.copy(firstName: firstName) : user;
    }).toList());
  }

  Future editLastName(User editUser) async {
    final lastName = await showTextDialog(
      context,
      title: 'Modifica cognome',
      value: editUser.lastName,
    );

    setState(() => users = users.map((user) {
      final isEditedUser = user == editUser;

      return isEditedUser ? user.copy(lastName: lastName) : user;
    }).toList());
  }
}