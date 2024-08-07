import 'package:flutter/material.dart';
import 'package:todo/sqld.dart';

class b1 extends StatefulWidget {
  const b1({Key? key}) : super(key: key);
  static const String route = '/b1';

  @override
  State<b1> createState() => _b1State();
}

class _b1State extends State<b1> {
  final Sqldb sqldb = Sqldb();
  int? _selectedIndex;

  Future<List<Map>> readData() async {
    List<Map> response = await sqldb.readData("SELECT * FROM notes");
    return response;
  }

  final GlobalKey<FormState> formstate = GlobalKey<FormState>();
  final TextEditingController task = TextEditingController();
  final TextEditingController date = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "Tasker",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 40, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white, size: 35),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      drawer: Drawer(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.blue,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  SizedBox(width: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '21 ',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Aug',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '2024',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map>>(
              future: readData(),
              builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, i) {
                      final taskData = snapshot.data![i];
                      bool isSelected = _selectedIndex == i;
                      return Card(
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = isSelected ? null : i;
                              });
                            },
                            child: Icon(
                              isSelected ? Icons.check_circle : Icons.circle,
                              color: isSelected ? Colors.blue : Colors.grey,
                            ),
                          ),
                          title: Text(
                            "${taskData['task']}",
                            style: TextStyle(
                              decoration: isSelected ? TextDecoration.lineThrough : null,
                              color: isSelected ? Colors.blue.shade700 : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            "${taskData['date']}",
                            style: TextStyle(
                              color: isSelected ? Colors.blue.shade700 : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No tasks found.'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(20.2),
                ),
              ),
              height: 450,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Add New Task",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Form(
                    key: formstate,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: task,
                            decoration: InputDecoration(
                              hintText: 'Task',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a task';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: date,
                            decoration: InputDecoration(
                              hintText: 'No due date',
                            ),
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () async {
                      DateTime? selectedDateTime = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDateTime != null) {
                        setState(() {
                          date.text = "${selectedDateTime.toLocal()}".split(' ')[0];
                        });
                      }
                    },
                    icon: Icon(Icons.calendar_month, color: Colors.blue),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16.0),
                        ElevatedButton(
                          onPressed: () async {
                            if (formstate.currentState?.validate() ?? false) {
                              int response = await sqldb.insertData('''
                                      INSERT INTO notes ('task', 'date')
                      VALUES ("${task.text}", "${date.text}" )
                      ''');
                              if (response > 0) {
                                setState(() {});
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: Text("Save"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            backgroundColor: Colors.transparent,
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
