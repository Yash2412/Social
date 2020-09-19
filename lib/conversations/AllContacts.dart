import 'package:Social/conversations/chatRoom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class AllContacts extends StatefulWidget {
  @override
  _AllContactsState createState() => _AllContactsState();
}

class _AllContactsState extends State<AllContacts> {
  List<dynamic> contacts = [];
  List<dynamic> contactsFiltered = [];
  String myNumber = FirebaseAuth.instance.currentUser.phoneNumber;
  TextEditingController searchController = new TextEditingController();
  String myUID = FirebaseAuth.instance.currentUser.uid;

  String numberWithCountryCode(String phoneStr) {
    phoneStr = phoneStr.replaceAll('-', '');
    phoneStr = phoneStr.replaceAll(',', '');
    phoneStr = phoneStr.replaceAll(' ', '');
    phoneStr = phoneStr.replaceAll('(', '');
    phoneStr = phoneStr.replaceAll(')', '');
    if (phoneStr.length >= 10)
      return "+91" + phoneStr.substring(phoneStr.length - 10);

    return "+91" + phoneStr;
  }

  validateNumber(phnFlattened) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    var snapshot = await users
        .where("phoneNumber", isEqualTo: phnFlattened)
        .limit(1)
        .get();
    return snapshot.docs;
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.undetermined;
    } else {
      return permission;
    }
  }

  getAllContacts() async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      List<Contact> _contacts = (await ContactsService.getContacts()).toList();

      _contacts.forEach((cont) {
        cont.phones.forEach((phn) {
          String phnFlattened = numberWithCountryCode(phn.value);
          validateNumber(phnFlattened).then((res) {
            if (res != null && res.length > 0) {
              setState(() {
                dynamic temp = res[0].data();
                if (temp['phoneNumber'] != myNumber) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(myUID)
                      .collection('SavedContacts')
                      .doc(temp['uid'])
                      .set(temp)
                      .then((value) => print('Contact list updated'));
                }
              });
            }
          });
        });
      });
    } else {
      //If permissions have been denied show standard cupertino alert dialog
      showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
                title: Text('Permissions error'),
                content: Text('Please enable contacts access '
                    'permission in system settings'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
    }
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  filterContacts() {
    List<dynamic> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact.data()['displayName'].toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        // var phone = contact.phones.firstWhere((phn) {
        //   String phnFlattened = flattenPhoneNumber(phn.value);

        // }, orElse: () => null);

        // return phone != null;
        return contact.data()["phoneNumber"].contains(searchTermFlatten);
      });
    }
    setState(() {
      contactsFiltered = _contacts;
    });
  }

  bool showSearch = false;

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;

    Stream collectionStream = FirebaseFirestore.instance
        .collection('users')
        .doc(myUID)
        .collection('SavedContacts')
        .orderBy('displayName', descending: false)
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black54, size: 30.0),
        title: (!showSearch)
            ? Text(
                "Select contact",
                style: TextStyle(fontSize: 22.0, color: Colors.black54),
              )
            : TextField(
                autofocus: true,
                controller: searchController,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: 'Search',
                    // floatingLabelBehavior: FloatingLabelBehavior.never,
                    contentPadding: EdgeInsets.only(bottom: 2.0))),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        titleSpacing: 20.0,
        actions: [
          IconButton(
              iconSize: 25.0,
              icon: Icon(
                (!showSearch) ? Icons.search : Icons.cancel,
                color: Colors.deepPurple,
              ),
              onPressed: () {
                setState(() {
                  showSearch = !showSearch;
                });
              }),
          if (!showSearch)
            IconButton(
                iconSize: 25.0,
                icon: Icon(Icons.refresh, color: Colors.deepPurple),
                onPressed: () {
                  getAllContacts();
                })
        ],
      ),
      body: Container(
          child: StreamBuilder(
              stream: collectionStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data.documents.length == 0) {
                  getAllContacts();
                  return Center(child: CircularProgressIndicator());
                }
                contacts = snapshot.data.documents;
                searchController.addListener(() {
                  filterContacts();
                });

                return ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider(
                        indent: 75.0,
                      );
                    },
                    itemCount: isSearching == true
                        ? contactsFiltered.length
                        : contacts.length,
                    itemBuilder: (context, index) {
                      dynamic contact = isSearching == true
                          ? contactsFiltered[index].data()
                          : contacts[index].data();
                      return ListTile(
                        onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoom(contact: contact),
                            )),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(contact['photoURL']),
                          maxRadius: 24.0,
                          minRadius: 20.0,
                        ),
                        title: Text(contact['displayName']),
                        // subtitle: Text('Here is a second line'),
                        subtitle: Text(contact['phoneNumber'] != ''
                            ? contact['phoneNumber']
                            : ''),
                        trailing: Icon(
                          Icons.arrow_right,
                          size: 30.0,
                        ),
                      );
                    });
              })),
    );
  }
}
/*
class Search extends SearchDelegate {
  String searchResult = '';

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return <Widget>[
      IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return Container(
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
            labelText: 'Search',
            border: new OutlineInputBorder(
                borderSide:
                    new BorderSide(color: Theme.of(context).primaryColor)),
            prefixIcon:
                Icon(Icons.search, color: Theme.of(context).primaryColor)),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions

    throw UnimplementedError();
  }
}
*/
