import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recherchelivraisonmedicament/core/constants/app_colors.dart';

import '../../../core/utils/valider_demande_function.dart';

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
        title: Text(
          "Demander un médicament",
          style: TextStyle(color: AppColors.surfacecolor, fontSize: 20),
        ),
        centerTitle: true,
        toolbarHeight: 64,
        backgroundColor: AppColors.primarycolor,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFloatingOptions,
        backgroundColor: AppColors.primarycolor,
        child: Icon(Icons.add, color: AppColors.surfacecolor),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: listeDemande.isEmpty
                  ? Center(child: Text("Liste vide ! Cliquez sur + pour ajouter."))
                  : ListView.builder(
                itemCount: listeDemande.length,
                itemBuilder: (context, index) {
                  final med = listeDemande[index];
                  return Card(
                    child: ListTile(
                      title: Text("${med['nom']} - ${med['dosage']} ${med['unite']} - Quantité : ${med['quantite']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => listeDemande.removeAt(index)),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (ordonnanceImage != null) ...[
              /*Container(
                height: 150,
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primarycolor),
                  image: DecorationImage(
                    image: FileImage(ordonnanceImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),*/
              Row(
                children: [
                  Icon(Icons.receipt_long, color: AppColors.primarycolor),
                  SizedBox(width: 8),
                  Expanded(child: Text("Ordonnance ajoutée")),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.visibility, color: AppColors.primarycolor,),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              content: Image.file(ordonnanceImage!),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => ordonnanceImage = null),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
            ],
            Divider(),
            SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Besoin urgent ?"),
                Switch(
                  value: besoinUrgent,
                  onChanged: (value) => setState(() => besoinUrgent = value),
                  activeColor: AppColors.primarycolor,
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                setState(() => _isLoading = true);

                final message = await submitDemande(
                  listeDemande: listeDemande,
                  ordonnanceImage: ordonnanceImage,
                  besoinUrgent: besoinUrgent,
                );

                if (!context.mounted) return;

                setState(() => _isLoading = false);

                if (message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                } else {
                  setState(() {
                    listeDemande.clear();
                    ordonnanceImage = null;
                    besoinUrgent = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Demande envoyée avec succès.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoading
                    ? Colors.grey.shade300
                    : Color(0xFF4CAF93).withValues(alpha: 1),
                minimumSize: Size(double.infinity, 48),
                elevation: 0,
              ),
              child: _isLoading
                  ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              )
                  : Text(
                "Valider la demande",
                style: TextStyle(color: AppColors.surfacecolor),
              ),
            ),
            SizedBox(height: 65)
          ],
        ),
      ),
    );
  }
}
