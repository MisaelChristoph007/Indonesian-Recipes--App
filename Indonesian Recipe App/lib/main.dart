import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MainPage(),
    );
  }
}

class Resep {
  final String name;
  final String image;
  final String description;
  final String region;

  Resep({
    required this.name,
    required this.image,
    required this.description,
    required this.region,
  });
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static List<Resep> reseps = [
    Resep(
      name: 'Nasi Timbel',
      image: 'https://via.placeholder.com/150',
      description: 'Nasi Timbel adalah hidangan nasi khas Sunda yang dibungkus daun pisang dan biasanya disajikan dengan berbagai lauk-pauk.',
      region: 'Sunda',
    ),
    Resep(
      name: 'Sate Maranggi',
      image: 'https://via.placeholder.com/150',
      description: 'Sate Maranggi adalah sate khas Sunda yang terbuat dari daging sapi atau kambing yang dimarinasi dengan bumbu khas dan dipanggang hingga matang.',
      region: 'Sunda',
    ),
  ];

  static List<Widget> _pages = <Widget>[
    HomePage(reseps: reseps),
    SearchPage(reseps: reseps),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecipePage(
                onAdd: (resep) {
                  setState(() {
                    reseps.add(resep);
                    _pages = <Widget>[
                      HomePage(reseps: reseps),
                      SearchPage(reseps: reseps),
                    ];
                  });
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<Resep> reseps;

  HomePage({required this.reseps});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedRegion = 'Sunda';

  @override
  Widget build(BuildContext context) {
    List<Resep> filteredReseps = widget.reseps.where((resep) => resep.region == selectedRegion).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Resep Masakan $selectedRegion'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedRegion,
            items: <String>[
              'Sunda', 'Jawa', 'Jakarta', 'Kalimantan', 'Sulawesi', 'Sumatra'
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedRegion = newValue!;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredReseps.length,
              itemBuilder: (context, index) {
                final resep = filteredReseps[index];
                return ListTile(
                  leading: Image.network(resep.image),
                  title: Text(resep.name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResepDetailPage(resep: resep),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  final List<Resep> reseps;

  SearchPage({required this.reseps});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Resep> _filteredReseps = [];

  void _searchResep() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredReseps = widget.reseps.where((resep) {
        return resep.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Recipes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchResep,
                ),
              ),
              onChanged: (value) {
                _searchResep();
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredReseps.length,
                itemBuilder: (context, index) {
                  final resep = _filteredReseps[index];
                  return ListTile(
                    leading: Image.network(resep.image),
                    title: Text(resep.name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResepDetailPage(resep: resep),
                        ),
                      );
                    },
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

class AddRecipePage extends StatefulWidget {
  final Function(Resep) onAdd;

  AddRecipePage({required this.onAdd});

  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedRegion = 'Sunda';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newResep = Resep(
        name: _nameController.text,
        image: _imageController.text,
        description: _descriptionController.text,
        region: _selectedRegion,
      );
      widget.onAdd(newResep);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedRegion,
                items: <String>[
                  'Sunda', 'Jawa', 'Jakarta', 'Kalimantan', 'Sulawesi', 'Sumatra'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRegion = newValue!;
                  });
                },
                decoration: InputDecoration(labelText: 'Region'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Add Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResepDetailPage extends StatelessWidget {
  final Resep resep;

  ResepDetailPage({required this.resep});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(resep.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image.network(resep.image),
            SizedBox(height: 16),
            Text(
              resep.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              resep.description,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}