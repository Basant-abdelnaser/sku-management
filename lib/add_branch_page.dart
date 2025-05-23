import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddBranchPage extends StatefulWidget {
  @override
  _AddBranchPageState createState() => _AddBranchPageState();
}

class _AddBranchPageState extends State<AddBranchPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();

  final DatabaseReference _branchesRef =
  FirebaseDatabase.instance.ref().child('branches');

  void _addBranch() {
    if (_formKey.currentState!.validate()) {
      final newBranchRef = _branchesRef.push();
      newBranchRef.set({
        'name': _nameController.text,
        'location': _locationController.text,
        'contact': _contactController.text,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Branch added successfully')),
        );
        _nameController.clear();
        _locationController.clear();
        _contactController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add branch: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Branch')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Branch Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter branch name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(labelText: 'Contact'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact details';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addBranch,
                  child: Text('Add Branch'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
