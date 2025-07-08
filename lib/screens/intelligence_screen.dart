import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/app_initialization_service.dart';

class IntelligenceScreen extends StatefulWidget {
  const IntelligenceScreen({Key? key}) : super(key: key);

  @override
  State<IntelligenceScreen> createState() => _IntelligenceScreenState();
}

class _IntelligenceScreenState extends State<IntelligenceScreen> {
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = AppInitializationService.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Intelligence'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading categories: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }

          final categories = snapshot.data!;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              // Dummy "AI" analysis: random percentage
              final percentage = 60 + (index * 7) % 40;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(category.icon, color: category.color),
                  title: Text(category.name),
                  subtitle: Text('AI Analysis Score: $percentage%'),
                  trailing: _getScoreIcon(percentage),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getScoreIcon(int percentage) {
    if (percentage >= 75) {
      return const Icon(Icons.thumb_up, color: Colors.green);
    } else if (percentage >= 50) {
      return const Icon(Icons.thumbs_up_down, color: Colors.orange);
    } else {
      return const Icon(Icons.thumb_down, color: Colors.red);
    }
  }
}