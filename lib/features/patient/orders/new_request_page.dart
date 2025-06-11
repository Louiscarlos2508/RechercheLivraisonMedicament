import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';

import '../../../core/utils/valider_demande_function.dart';
import 'choose_delevery_location_page.dart';

class NewRequestPage extends StatefulWidget {
  const NewRequestPage({super.key});

  @override
  State<NewRequestPage> createState() => _NewRequestPageState();
}

class _NewRequestPageState extends State<NewRequestPage> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController quantiteController = TextEditingController();
  String uniteDosage = 'mg';
  List<Map<String, dynamic>> listeDemande = [];
  bool besoinUrgent = false;
  File? ordonnanceImage;
  bool _isLoading = false;


  void _showFloatingOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.medication, color: AppColors.primarycolor),
              title: Text('Ajouter un médicament'),
              onTap: () {
                Navigator.pop(context);
                _showAddMedicamentSheet();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primarycolor),
              title: Text('Ajouter une ordonnance'),
              onTap: () {
                Navigator.pop(context);
                _addOrdonnance();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddMedicamentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                decoration: InputDecoration(
                  labelText: 'Nom du médicament',
                  border: OutlineInputBorder(),
                    floatingLabelStyle: TextStyle(color: AppColors.primarycolor),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: const BorderSide(width: 2, color: AppColors.primarycolor)
                    )
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: dosageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // N'autorise que les chiffres
                      ],
                      decoration: InputDecoration(
                        labelText: 'Dosage',
                        border: OutlineInputBorder(),
                          floatingLabelStyle: TextStyle(color: AppColors.primarycolor),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: const BorderSide(width: 2, color: AppColors.primarycolor)
                          )
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: uniteDosage,
                      items: ['mg', 'ml', 'g'].map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => uniteDosage = value!),
                      decoration: InputDecoration(
                        labelText: 'Unité',
                        border: OutlineInputBorder(),
                          floatingLabelStyle: TextStyle(color: AppColors.primarycolor),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: const BorderSide(width: 2, color: AppColors.primarycolor)
                          )
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              TextField(
                controller: quantiteController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // N'autorise que les chiffres
                ],
                decoration: InputDecoration(
                  labelText: 'Quantité',
                  border: OutlineInputBorder(),
                    floatingLabelStyle: TextStyle(color: AppColors.primarycolor),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: const BorderSide(width: 2, color: AppColors.primarycolor)
                    )
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final nom = nomController.text.trim();
                  final dosage = dosageController.text.trim();
                  final quantite = quantiteController.text.trim();

                  if (nom.isNotEmpty && dosage.isNotEmpty && quantite.isNotEmpty) {
                    setState(() {
                      listeDemande.add({
                        'nom': nom,
                        'dosage': dosage,
                        'unite': uniteDosage,
                        'quantite': quantite,
                        'prix': null,
                      });
                      nomController.clear();
                      dosageController.clear();
                      quantiteController.clear();
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primarycolor,
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text("Ajouter à la liste", style: TextStyle(color: AppColors.surfacecolor)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickOrdonnanceImage(ImageSource source) async {
    PermissionStatus status;

    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      status = await Permission.photos.request();
    }

    if (!mounted) return;

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permission refusée")),
      );
      return;
    }

    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );

    if (!mounted) return;

    if (pickedFile != null) {
      setState(() {
        ordonnanceImage = File(pickedFile.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ordonnance ajoutée avec succès !")),
      );
    }
  }



  void _addOrdonnance() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primarycolor),
              title: Text("Prendre une photo"),
              onTap: () {
                Navigator.pop(context);
                _pickOrdonnanceImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primarycolor),
              title: Text("Choisir depuis la galerie"),
              onTap: () {
                Navigator.pop(context);
                _pickOrdonnanceImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        title: const Text("Nouvelle demande", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.surfacecolor)),
        centerTitle: true,
        backgroundColor: AppColors.primarycolor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFloatingOptions,
        backgroundColor: AppColors.primarycolor,
        child: const Icon(Icons.add, color: Colors.white,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: listeDemande.isEmpty
                  ? const Center(child: Text("Aucun médicament ajouté. Cliquez sur + pour commencer."))
                  : ListView.separated(
                itemCount: listeDemande.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final med = listeDemande[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primarycolor.withValues(alpha: 0.1),
                        child: Icon(Icons.medication, color: AppColors.primarycolor),
                      ),
                      title: Text(
                        med['nom'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Dosage : ${med['dosage']} ${med['unite']} • Quantité : ${med['quantite']}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => listeDemande.removeAt(index)),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (ordonnanceImage != null) ...[
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primarycolor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long, color: AppColors.primarycolor),
                    const SizedBox(width: 12),
                    const Expanded(child: Text("Ordonnance ajoutée")),
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      color: AppColors.primarycolor,
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          content: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(ordonnanceImage!),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => ordonnanceImage = null),
                    ),
                  ],
                ),
              ),
            ],

            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Besoin urgent ?", style: TextStyle(fontSize: 16)),
                Switch(
                  value: besoinUrgent,
                  onChanged: (val) => setState(() => besoinUrgent = val),
                  activeColor: AppColors.primarycolor,
                ),
              ],
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoading ? Colors.grey.shade300 : AppColors.primarycolor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text("Valider la demande", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);

    final result = await submitDemande(
      listeDemande: listeDemande,
      ordonnanceImage: ordonnanceImage,
      besoinUrgent: besoinUrgent,
    );

    if (!mounted) return;

    setState(() => _isLoading = false); // ✅ Toujours désactiver le loader ici

    if (result == null || result.startsWith("Erreur") || result == "Utilisateur non connecté") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ?? "Une erreur est survenue."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Demande envoyée avec succès")),
    );

    final demandeId = result;
    setState(() {
      listeDemande.clear();
      ordonnanceImage = null;
      besoinUrgent = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChooseDeliveryLocationPage(demandeId: demandeId),
      ),
    );
  }
}


