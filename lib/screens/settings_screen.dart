import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  // Function to Edit Username
  void _editUsername(AuthService auth) {
    // If name is "User" (placeholder), start with empty text field for easier typing
    String currentName = auth.currentUser?.displayName ?? '';
    if (currentName == 'User') currentName = '';

    final TextEditingController nameController = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Username'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Enter new username"),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              Navigator.pop(context); // Close dialog
              setState(() => _isLoading = true);
              
              try {
                await auth.updateDisplayName(nameController.text.trim());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username updated!')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    // Fallback values
    // Handle both null AND empty string
    String displayName = user?.displayName ?? 'User';
    if (displayName.trim().isEmpty) displayName = 'User';
    
    final String email = user?.email ?? 'No Email';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Name Row with Edit Button
                // Use an invisible button on the left to perfectly center the text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Invisible dummy button for balance
                    const Opacity(
                      opacity: 0.0,
                      child: IconButton(
                        icon: Icon(Icons.edit, size: 20),
                        onPressed: null,
                      ),
                    ),
                    
                    // The actual name
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    
                    // The real edit button
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                      onPressed: () => _editUsername(auth),
                    ),
                  ],
                ),
                
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await auth.signOut();
            },
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            trailing: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}