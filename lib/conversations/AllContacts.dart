import 'package:Social/conversations/chatRoom.dart';
import 'package:Social/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

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
  bool loading = true;

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

  checkUpdate(contact) {
    FirebaseFirestore.instance
        .doc('users/${contact['uid']}')
        .get()
        .then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(myUID)
          .collection('RecentChats')
          .doc(contact['uid'])
          .update(value.data());
    });
  }

  getAllContacts() async {
    if (await Permission.contacts.request().isGranted) {
      setState(() {
        loading = true;
      });
      List<Contact> _contacts = (await ContactsService.getContacts()).toList();
      _contacts.forEach((cont) {
        cont.phones.forEach((phn) {
          String phnFlattened = numberWithCountryCode(phn.value);
          validateNumber(phnFlattened).then((res) {
            if (res != null && res.length > 0) {
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
            }
          });
        });
      });
      setState(() {
        loading = false;
      });
    } else {
      //If permissions have been denied show standard cupertino alert dialog

      Toast.show(
        "Opps! Permission Denied!",
        context,
        duration: Toast.LENGTH_SHORT,
        gravity: Toast.BOTTOM,
      );
    }
  }

  initState() {
    super.initState();
    getAllContacts();
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
      backgroundColor: background,
      appBar: AppBar(
        iconTheme: IconThemeData(color: forground, size: 30.0),
        title: (!showSearch)
            ? Text(
                "Select contact",
                style: TextStyle(fontSize: 22.0, color: forground),
              )
            : TextField(
                autofocus: true,
                controller: searchController,
                style: TextStyle(fontSize: 18, color: forground),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: 'Search',
                    // floatingLabelBehavior: FloatingLabelBehavior.never,
                    contentPadding: EdgeInsets.only(bottom: 2.0))),
        backgroundColor: background,
        automaticallyImplyLeading: true,
        titleSpacing: 20.0,
        actions: [
          IconButton(
              iconSize: 25.0,
              icon: Icon(
                (!showSearch) ? Icons.search : Icons.cancel,
              ),
              onPressed: () {
                setState(() {
                  showSearch = !showSearch;
                });
              }),
          if (!showSearch)
            IconButton(
                iconSize: 25.0,
                icon: Icon(Icons.refresh),
                onPressed: () {
                  getAllContacts();
                })
        ],
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: loading ? 0.25 : 1,
            child: Container(
                child: StreamBuilder(
                    stream: collectionStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
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
                                    builder: (context) =>
                                        ChatRoom(contact: contact),
                                  )),
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(contact['photoURL']),
                                maxRadius: 20.0,
                                minRadius: 20.0,
                              ),
                              title: Text(
                                contact['displayName'],
                                style: TextStyle(
                                    color: forground,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600),
                              ),
                              // subtitle: Text('Here is a second line'),
                              subtitle: Text(
                                contact['phoneNumber'] != ''
                                    ? contact['phoneNumber']
                                    : '',
                                style: TextStyle(color: cyan),
                              ),
                              trailing: Icon(
                                Icons.arrow_right,
                                size: 30.0,
                              ),
                            );
                          });
                    })),
          ),
          if (loading)
            Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    backgroundColor: background,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text('Loading...'),
              ],
            ))
        ],
      ),
    );
  }
}
