import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projekt_webshop/consts/validator.dart';
import 'package:projekt_webshop/root_screen.dart';
import 'package:projekt_webshop/screens/loading_manager.dart';
import 'package:projekt_webshop/services/my_app_functions.dart';
import 'package:projekt_webshop/widgets/app_name_text.dart';
import 'package:projekt_webshop/widgets/auth/image_picker_widget.dart';
import 'package:projekt_webshop/widgets/subtitle_text.dart';
import 'package:projekt_webshop/widgets/title_text.dart';

class RegisterScreen extends StatefulWidget {
  static const routName = "/RegisterScreen";
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool obscureText = true;
  late final TextEditingController
  _nameController,
  _emailController,
  _passwordController,
  _repeatPasswordController;

  late final FocusNode
  _nameFocusNode,
  _emailFocusNode,
  _passwordFocusNode,
  _repeatPasswordFocusNode;

  final _formkey = GlobalKey<FormState>();
  XFile? _pickedImage;
  bool _isLoading = false;
  final auth = FirebaseAuth.instance;
  String? userImageUrl;

  @override
  void initState() {
    _nameController =  TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _repeatPasswordController = TextEditingController();
    // Focus Nodes
    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _repeatPasswordFocusNode = FocusNode();
    super.initState();
    
  }

  @override
  void dispose() {
    if(mounted){
      _nameController.dispose();
      _emailController.dispose();
      _passwordController.dispose();
      _repeatPasswordController.dispose();
    // Focus Nodes
      _nameFocusNode.dispose();
      _emailFocusNode.dispose();
      _passwordFocusNode.dispose();
      _repeatPasswordFocusNode.dispose();
    }
    super.dispose();
  }

  // _registerFCT služi za provjeru valjanosti unesenih podataka u formi, stvaranje korisničkog računa putem Firebase Authentication,
  // pohranu korisničkih podataka i slike profila u Firebase bazu podataka i Storage te upravljanje greškama prilikom registracije,
  // sve to uz ažuriranje UI-a i prikaz odgovarajućih poruka korisniku.
  Future<void> _registerFCT () async {
    final isValid = _formkey.currentState!.validate(); //provjera polja za tekst
    FocusScope.of(context).unfocus();

    if(_pickedImage == null) {
      MyAppFunctions.showErrorOrWarningDialog(
        context: context,
      subtitle: "Make sure to pick up a image",
      fct: () {},
      );
      return;
    }
    if(isValid) {
      try{
        setState(() {
          _isLoading = true;
        });
        
      await auth.createUserWithEmailAndPassword( // s ovim dopuštamo korisnicima da se registriraju
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ); // ako postoji greška kod prestaje ovdje i ovo ispod neće biti odrađeno nego preskače na catch blok

      final User? user =auth.currentUser;
      final String uid = user!.uid;

      // U Firebasu storag-u stvaramo folder koji će sadržavati slike koriskika
      final ref = FirebaseStorage.instance
          .ref()
          .child("usersImages")
          .child("${_emailController.text.trim()}.jpg"); // kreirana putanja slike
          
      await ref.putFile(File(_pickedImage!.path)); // u ovom dijelu push-amo file u firebase storage
      userImageUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection("users").doc(uid).set({
          'userId': uid,
          'userName': _nameController.text,
          'userImage': userImageUrl,
          'userEmail': _emailController.text.toLowerCase(),
          'createdAt': Timestamp.now(),
          'userWish': [],
          'userCart': [],
        });
      Fluttertoast.showToast( // kod dodna sa pub dev primjera za flutter toast proširenje
        msg: "An account has been created",
        textColor: Colors.white,
    );
      if(!mounted) return;
      Navigator.pushReplacementNamed(context, RootScreen.routName);

      }on FirebaseException catch (error){
        await MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: error.message.toString(),
          fct: () {},
        );
      }catch (error) {
        await MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: error.toString(),
          fct: () {},
        );
      } finally{
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

// koristi se za odabir slike profila korisnika s lokalnog uređaja
  Future<void> localImagePicker() async {
    final ImagePicker imagePicker = ImagePicker();
    await MyAppFunctions.imgaePickerDialog(
      context: context,
      cameraFCT: () async {
        _pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
        setState(() {
        });
      },
      galleryFCT:  () async {
        _pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
        setState(() {
        });
      },
      removeFCT: () {
        setState(() {
          _pickedImage = null;
        });
      },
      );
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      //kod prikaza tipkovnice možemo pritisnuti bilo gdje na ekran i on će se zatvoriti
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: LoadingManager(
          isLoading: _isLoading,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // const BackButton(),
                  const SizedBox(
                    height: 60,
                    ),
        
                    // TEXT WIDGEET NASLOVA
                  const AppNameTextWidget(
                    fontSize: 30,
                    ),
                  const SizedBox(
                    height: 30,
                    ),
        
                    // TEXT
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitlesTextWidget(label: "Welcome back!"),
                        SubtitleTextWidget(label: "Your welcome message")
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                    ),
        
                  SizedBox(
                    height: size.width * 0.3,
                    width: size.width * 0.3,
                    child: PickImageWidget(
                      pickedImage: _pickedImage,
                      function: () async {
                        await localImagePicker();
                      },
                      ),
                    ),
                  const SizedBox(
                    height: 30,
                    ),
        
                  Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
        
                        //  Full Name POLJE ZA UNOS
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            hintText: "Full Name",
                            prefixIcon: Icon(
                              Icons.person,
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(_emailFocusNode);
                          },
                          validator: (value) { // poruka ispod polja koja se javlja ako je polje ostalo prazno
                            return MyValidators.displayNamevalidator(value);
                          }
                        ),
        
                        const SizedBox(
                          height: 16,
                        ),
                        
                        //  Email address POLJE ZA UNOS
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "Email address",
                            prefixIcon: Icon(
                              IconlyLight.message,
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(_passwordFocusNode);
                          },
                          validator: (value) { // poruka ispod polja koja se javlja ako je polje ostalo prazno
                            return MyValidators.emailValidator(value);
                          }
                        ),
                        const SizedBox(
                          height: 16,
                        ),
        
                        //  PASSWORD POLJE ZA UNOS
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: obscureText,
                          decoration: InputDecoration(
                            hintText: "**********",
                            prefixIcon: const Icon(
                              IconlyLight.lock,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                              icon: Icon(
                                obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              ),
                            ),
                          ),
                          onFieldSubmitted: (value) async{
                            FocusScope.of(context).requestFocus(_repeatPasswordFocusNode);
                          },
                           validator: (value) { // poruka ispod polja za lozinku koja se javlja ako je polje ostalo prazno
                            return MyValidators.passwordValidator(value);
                          }
                        ),
                        const SizedBox(
                          height: 16,
                        ),
        
                        TextFormField(
                          controller: _repeatPasswordController,
                          focusNode: _repeatPasswordFocusNode,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: obscureText,
                          decoration: InputDecoration(
                            hintText: "Repeat password",
                            prefixIcon: const Icon(
                              IconlyLight.lock,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                              icon: Icon(
                                obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              ),
                            ),
                          ),
                          onFieldSubmitted: (value) async{
                            await _registerFCT();
                          },
                           validator: (value) { // poruka ispod polja za lozinku koja se javlja ako je polje ostalo prazno
                            return MyValidators.repeatPasswordValidator(
                              value: value,
                              password: _passwordController.text);
                          }
                        ),
                        const SizedBox(
                          height: 16,
                        ),
        
                        
                        SizedBox(
                          width: double.infinity, //proširiva ikonu sing upa preko cijele širine ekrana
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(12.0),
                              // backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          icon: const Icon(IconlyLight.addUser),
                          label: const Text("Sing up"),
                          onPressed: () async{
                              await _registerFCT();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}