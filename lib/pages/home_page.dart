import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_firebase_crud/services/firestore.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Local boolean to toggle QuerySnapshot as ascending/descending
  bool _isDescending = true;

  // Firestore service
  final FirestoreService firestoreService = FirestoreService();

  // Open a dialog box to add/edit a note
  void openToDoBox({String? docId, String? currentText}) {
    // TextController for dialog box
    final TextEditingController textController =
        TextEditingController(text: currentText);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: docId == null
                  ? const Text("Add To Do")
                  : const Text("Edit To Do"),
              // User text input goes here
              content: TextField(
                controller: textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Enter your to do",
                ),
              ),
              actions: [
                // Buttons to save or cancel
                ElevatedButton(
                    onPressed: () {
                      // Add / edit a new note
                      if (docId == null) {
                        firestoreService.addToDo(textController.text);
                      } else {
                        firestoreService.updateToDo(docId, textController.text);
                      }
                      // Clear the text field
                      textController.clear();
                      // Close dialog after adding note
                      Navigator.pop(context);
                    },
                    child: docId == null
                        ? const Text("Add")
                        : const Text("Update")),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("To Do App")),
      floatingActionButton: FloatingActionButton(
        onPressed: openToDoBox,
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: SizedBox(
          width: 800.0,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sort by date"),
                  IconButton(
                      onPressed: () {
                        // Toggle _isDescending
                        setState(() {
                          _isDescending = !_isDescending;
                        });
                      },
                      icon: Icon(_isDescending
                          ? Icons.arrow_downward
                          : Icons.arrow_upward)),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.getToDoStream(_isDescending),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      // If we have data, return all the docs
                      List todoList = snapshot.data!.docs;
                
                      // Display as a list
                      return ListView.builder(
                        itemCount: todoList.length,
                        itemBuilder: (context, index) {
                          // Get each individual document
                          DocumentSnapshot document = todoList[index];
                          String docId = document.id;
                
                          // Get data from the document
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          String todoText = data['todo'];
                
                          // Display as a ListTile
                          return Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(blurRadius: 5, color: Colors.grey)
                                ],
                                borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              title: data['done']
                                  ? Text(
                                      todoText,
                                      style: const TextStyle(
                                          decoration: TextDecoration.lineThrough),
                                    )
                                  : Text(todoText),
                              leading: Checkbox(
                                  value: data['done'],
                                  onChanged: (value) async {
                                    await firestoreService.toggleToDo(docId, value!);
                                  }),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async => openToDoBox(
                                      docId: docId,
                                      currentText: todoText,
                                    ),
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      // Delete the todo
                                      await firestoreService.deleteToDo(docId);
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      // If there's no data, return "No To Dos"
                      return const Center(child: Text("No To Dos"));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
