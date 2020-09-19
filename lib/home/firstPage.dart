import 'package:flutter/material.dart';

class CookiePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 15.0,
      childAspectRatio: 0.8,
      children: <Widget>[
        _buildCard('Ashu Bitches', ''),
        _buildCard('CSE Masti', '555'),
        // _buildCard('Ashu Bitches', ''),
        // _buildCard('CSE Masti', ''),
        // _buildCard('Ashu Bitches', ''),
        // _buildCard('CSE Masti', ''),
        // _buildCard('Ashu Bitches', ''),
        // _buildCard('CSE Masti', ''),
        // _buildCard('Ashu Bitches', ''),
        // _buildCard('CSE Masti', ''),
        // _buildCard('Ashu Bitches', ''),
        // _buildCard('CSE Masti', ''),
        // _buildCard('Ashu Bitches', ''),
        // _buildCard('CSE Masti', ''),
        // _buildCard('Ashu Bitches', ''),
        // _buildCard('CSE Masti', ''),
        // _buildCard('Ashu Bitches', ''),
        // _buildCard('CSE Masti', ''),
        // _buildCard('Ashu Bitches', ''),
        // _buildCard('CSE Masti', ''),
      ],
    ));
  }

  Widget _buildCard(String name, String imgPath) {
    return Padding(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
        child: InkWell(
            onTap: () {},
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3.0,
                          blurRadius: 5.0)
                    ],
                    color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    // Padding(
                    //     padding: EdgeInsets.all(5.0),
                    //     child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.end,
                    //         children: [])),
                    Hero(
                      tag: imgPath,
                      child: CircleAvatar(
                        radius: 60.0,
                        backgroundImage:
                            NetworkImage('https://picsum.photos/2000/1500'),
                      ),
                      // child: Container(
                      //     height: 75.0,
                      //     width: 75.0,
                      //     decoration: BoxDecoration(
                      //         image: DecorationImage(
                      //             image: NetworkImage(
                      //                 'https://picsum.photos/2000/1500'),
                      //             fit: BoxFit.contain)))
                    ),
                    Text(
                      name,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 18.0),
                    )
                  ]),
                ))));
  }
}
