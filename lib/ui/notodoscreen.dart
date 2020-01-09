import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:no_to_do/model/notodo_item.dart';
import 'package:no_to_do/utils/database_client.dart';
import 'package:no_to_do/utils/date_formatter.dart';

class NotodoScreen extends StatefulWidget {
  @override
  _NotodoScreenState createState() => _NotodoScreenState();
}

class _NotodoScreenState extends State<NotodoScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  var db = DatabaseHelper();
  final List<NoToItem> _itemlist = <NoToItem>[];


  @override
  void initState() {
    super.initState();

    _readNoDoList();
  }

  void _handleSubmit(String text) async {
    _textEditingController.clear();

    NoToItem noToItem = NoToItem(text, dateFormatted());
    int savedItemId = await db.saveItem(noToItem);
   NoToItem addedItem = await db.getItem(savedItemId);

   setState(() {
     _itemlist.insert(0, addedItem);
   });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: false,
              itemCount: _itemlist.length,
              itemBuilder: (_, int index){
                return Card(
                  color: Colors.white10,
                  child: ListTile(
                    title: _itemlist[index],
                    onLongPress: () => _updateItem(_itemlist[index] , index),
                    trailing: Listener(
                      key: Key(_itemlist[index].itemName),
                      child: Icon(Icons.remove_circle ,
                      color: Colors.redAccent,),
                      onPointerDown: (pointerEvent) => 
                      _deleteNoTo(_itemlist[index].id , index),
                    ),
                  ),
                );
              },
            )
          ),
          Divider(
            height: 1.0,
          )
        ],
      ),


      floatingActionButton: FloatingActionButton(
        tooltip: "Add Item",
        backgroundColor: Colors.red,
        child: ListTile(
          title: Icon(Icons.add),
        ),
        onPressed: _showFormDialog,
      ),
    );
  }

  void _showFormDialog() {
    var alert = AlertDialog(
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                  labelText: "Item",
                  hintText: "e.g: Don't buy Stuff",
                  icon: Icon(Icons.note_add)),
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              _handleSubmit(_textEditingController.text);
              Navigator.pop(context);
            },
            child: Text("Save")),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        )
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }
  _readNoDoList() async{
    List items = await db.getItems();
    items.forEach((item){
      setState(() {
        _itemlist.add(NoToItem.map(item));
      });
//      NoToItem noToItem = NoToItem.map(item);
//      print("Db items: ${noToItem.itemName}");
    });
  }

  _deleteNoTo(int id, int index) async {
    debugPrint("Deleted Item!");

    await db.deleteUser(id);
    setState(() {
      _itemlist.removeAt(index);
    });
  }

  _updateItem(NoToItem item ,int index) {
    var alert = AlertDialog(
      title: Text("Update Item"),
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                  labelText: "Item",
                  hintText: "e.g: Don't buy Stuff",
                  icon: Icon(Icons.update)),
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () async {
                NoToItem newItemUpdated = NoToItem.fromMap(
                  {"itemName": _textEditingController.text,
                    "dateCreated" : dateFormatted(),
                    "id" : item.id,
                  });
                _handleSubmitUpdate(index , item);//redrawing the screen
                await db.updateUser(newItemUpdated);//updating the item
                setState(() {
                  _readNoDoList();//redrawing the screen with all saved in the db
                });
              Navigator.pop(context);
            },
            child: Text("Update")),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        )
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  void _handleSubmitUpdate(int index, NoToItem item) {
   setState(() {
     _itemlist.removeWhere((element){
       _itemlist[index].itemName == item.itemName;
     });
   });
  }

}
