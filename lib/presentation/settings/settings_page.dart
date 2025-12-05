import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayarlar"),
        backgroundColor: const Color(0xFF592EC3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(user?.email ?? "-"),
              subtitle: Text("Kullanıcı ID: ${user?.uid}"),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text("Parola Sıfırla"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                if (user?.email != null) {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: user!.email!,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Parola sıfırlama maili gönderildi."),
                    ),
                  );
                }
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text("Tema Ayarı"),
              subtitle: const Text("Yakında..."),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text("Çıkış Yap"),
          ),
        ],
      ),
    );
  }
}
