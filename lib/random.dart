import 'package:flutter/material.dart';

class MyListView extends StatefulWidget {
  @override
  MyListViewState createState() => MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  List<ListItem> _listItems = [
    ListItem(title: 'Item 1'),
    ListItem(title: 'Item 2'),
    ListItem(title: 'Item 3'),
    ListItem(title: 'Item 4'),
    ListItem(title: 'Item 5'),
  ];

  @override
  Widget build(BuildContext context) {
    int numChecked = _listItems.where((item) => item.isChecked).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('My List View'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: Column(
          children: [
            CircularProgressIndicator(
              value: numChecked / _listItems.length,
              backgroundColor: Colors.orange,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _listItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: _listItems[index].isChecked
                        ? Colors.green
                        : Colors.white,
                    child: CheckboxListTile(
                      title: Text(_listItems[index].title),
                      value: _listItems[index].isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          _listItems[index].isChecked = value!;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListItem {
  String title;
  bool isChecked;

  ListItem({required this.title, this.isChecked = false});
}