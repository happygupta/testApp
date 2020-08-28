import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'main.dart';

List add = [], load = [];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _textFieldController = TextEditingController();
  var item;
  bool isLoading = true;

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Items'),
            content: TextField(
              controller: _textFieldController,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(hintText: "Enter item name"),
              onChanged: (val) {
                item = val;
              },
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Submit'),
                onPressed: () {
                  load.add(item);
                  box.put('loadItem', load);
                  _textFieldController.clear();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  bool contains(int index, element) {
    bool t = true;
    for (int i = 0; i < index; i++) {
      if (add[i] == element) {
        t = false;
        break;
      } else
        t = true;
    }
    return t;
  }

  int Check(List list, element) {
    if (list == null || list.isEmpty) {
      return 0;
    }
    var foundElements = list.where((e) => e == element);
    return foundElements.length;
  }

  Future Return() async {
    await showSearch(context: context, delegate: SearchItems());
    setState(() {});
  }

  Future wait() async {
    add = await box.get('addItem', defaultValue: []);
    load = await box.get('loadItem', defaultValue: []);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    wait();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Items',
          style: GoogleFonts.saira(),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.add_to_photos,
                color: Colors.black,
              ),
              onPressed: () => _displayDialog(context)),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(55),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 12, bottom: 8, right: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24)),
                  child: InkWell(
                    onTap: () {
                      Return();
//                        showSearch(context: context, delegate: SearchItems());
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                            hintText: 'Search Items',
                            contentPadding: EdgeInsets.only(left: 24),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: add.isEmpty
                  ? Center(
                      child: Text(
                        'No Items Found..',
                        style: GoogleFonts.saira(
                            fontSize: 22, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: add.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final listItem = add[index];
                        return contains(index, listItem)
                            ? Card(
                                child: ListTile(
                                  title: Text(
                                    listItem,
                                    style: GoogleFonts.tinos(fontSize: 18),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      IconButton(
                                          icon:
                                              Icon(Icons.remove_circle_outline),
                                          onPressed: () {
                                            setState(() {
                                              add.remove(listItem);
                                              box.put('addItem', add);
                                            });
                                          }),
                                      Text(Check(add, listItem).toString()),
                                      IconButton(
                                          icon: Icon(Icons.add_circle_outline),
                                          onPressed: () {
                                            setState(() {
                                              add.add(listItem);
                                              box.put('addItem', add);
                                            });
                                          }),
                                    ],
                                  ),
                                ),
                              )
                            : Container();
                      },
                    ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Text(
          add.length.toString() + " - Items in Cart",
          style: GoogleFonts.saira(fontSize: 18),
        ),
      ),
    );
  }
}

class SearchItems extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text(query));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var myList = query.isEmpty
        ? load
        : load.where((element) => element.startsWith(query)).toList();
    return myList.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              'No Results Found..',
              style: GoogleFonts.saira(fontSize: 22, color: Colors.black54),
            ),
          )
        : ListView.builder(
            itemCount: myList.length,
            itemBuilder: (context, index) {
              final listItem = myList[index];
              return ListTile(
                onTap: () {
                  if (add.contains(listItem)) {
                  } else {
                    add.add(listItem);
                    box.put('addItem', add);
                    close(context, null);
                  }
                },
                title: Text(listItem),
                trailing: add.contains(listItem)
                    ? Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                    : Icon(
                        Icons.add_circle,
                        color: Colors.blue,
                      ),
              );
            },
          );
  }
}
