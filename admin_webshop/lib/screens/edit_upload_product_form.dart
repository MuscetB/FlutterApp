import 'dart:io';

import 'package:admin_webshop/consts/app_constants.dart';
import 'package:admin_webshop/consts/validator.dart';
import 'package:admin_webshop/models/product_model.dart';
import 'package:admin_webshop/screens/loading_manager.dart';
import 'package:admin_webshop/services/my_app_functions.dart';
import 'package:admin_webshop/widgets/subtitle_text.dart';
import 'package:admin_webshop/widgets/title_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class EditOrUploadProductScreen extends StatefulWidget {
  static const routeName = '/EditOrUploadProductScreen';

  const EditOrUploadProductScreen({super.key, this.productModel});
  final ProductModel? productModel;

  @override
  State<EditOrUploadProductScreen> createState() => _EditOrUploadProductScreenState();
}

class _EditOrUploadProductScreenState extends State<EditOrUploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;

  late TextEditingController
    _titleController,
    _priceController,
    _descriptionController,
    _quantityController;
  
  String? _categoryValue;
  bool isEditing = false;
  String? productNetworkImage;
  bool _isLoading = false;
  String? productImageUrl;
  @override
  void initState() {
    if (widget.productModel != null) {
      isEditing = true;
      productNetworkImage = widget.productModel!.productImage;
      _categoryValue = widget.productModel!.productCategory;
    }
    _titleController = TextEditingController(text: widget.productModel?.productTitle); // PROUČI OVAJ ?
    _priceController = TextEditingController(text: widget.productModel?.productPrice);
    _descriptionController = TextEditingController(text: widget.productModel?.productDescription);
    _quantityController = TextEditingController(text: widget.productModel?.productQuantity);

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();

    super.dispose();
  }

  void clearForm() {
    _titleController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _quantityController.clear();

    removePickedImage();
  }

  void removePickedImage() {
    setState(() {

      _pickedImage = null;
      productNetworkImage = null;
    });
  }

  Future<void> _uploadProduct() async {
    final isValid = _formKey.currentState!.validate(); //provjera polja za tekst
    FocusScope.of(context).unfocus();

  // ovo koristimo za baratanje grešaka??
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
      
      final productId = const Uuid().v4();
      // U Firebasu storag-u stvaramo folder koji će sadržavati slike koriskika
      final ref = FirebaseStorage.instance
          .ref()
          .child("productsImages")
          .child("$productId.jpg"); // kreirana putanja slike
          
      await ref.putFile(File(_pickedImage!.path)); // u ovom dijelu push-amo file u firebase storage
      productImageUrl = await ref.getDownloadURL();

      
        await FirebaseFirestore.instance
            .collection("products")
            .doc(productId) // widget.productModel!.productId
            .set({
          'productId': productId,
          'productTitle': _titleController.text,
          'productPrice': _priceController.text,
          'productImage': productImageUrl,
          'productCategory': _categoryValue,
          'productDescription': _descriptionController.text,
          'productQuantity': _quantityController.text,
          'createdAt': Timestamp.now()
        });

      Fluttertoast.showToast( // kod dodna sa pub dev primjera za flutter toast proširenje
        msg: "Product has been added",
        textColor: Colors.white,
    );
      if(!mounted) return;
      MyAppFunctions.showErrorOrWarningDialog(
        isError: false,
        context: context,
        subtitle: "Clear form?",
        fct: (){
          clearForm();
        }
        );
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

  Future<void> _editProduct() async {
    final isValid = _formKey.currentState!.validate(); //provjera polja za tekst
    FocusScope.of(context).unfocus();

    if(_pickedImage == null && productNetworkImage == null) {
      MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: "Please pick up an image",
        fct: () {},
      );
      return;
    }
    if(isValid) { //prikazivanje loading indikatora
      try{
        setState(() {
          _isLoading = true;
        });
      // U Firebasu storag-u stvaramo folder koji će sadržavati slike koriskika, ovaj dio koda dopušta korisniku uploud u firestore 
      if (_pickedImage != null) {
        final ref = FirebaseStorage.instance
          .ref()
          .child("productsImages")
          .child("${_titleController.text}.jpg"); // kreirana putanja slike
    
      await ref.putFile(File(_pickedImage!.path)); // u ovom dijelu push-amo file u firebase storage
      productImageUrl = await ref.getDownloadURL();
      }

      
        await FirebaseFirestore.instance
            .collection("products")
            .doc(widget.productModel!.productId)
            .update({ // koristimo update
          'productId': widget.productModel!.productId,
          'productTitle': _titleController.text,
          'productPrice': _priceController.text,
          'productImage': productImageUrl ?? productNetworkImage,
          'productCategory': _categoryValue,
          'productDescription': _descriptionController.text,
          'productQuantity': _quantityController.text,
          'createdAt': widget.productModel!.createdAt,
        });

      Fluttertoast.showToast( // kod dodna sa pub dev primjera za flutter toast proširenje
        msg: "Product has been edited",
        textColor: Colors.white,
    );
      if(!mounted) return;
      MyAppFunctions.showErrorOrWarningDialog(
        isError: false,
        context: context,
        subtitle: "Clear form?",
        fct: (){
          clearForm();
        }
        );
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

  Future<void> localImagePicker() async {
    final ImagePicker picker = ImagePicker();
    await MyAppFunctions.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.camera);
        setState(() { productNetworkImage = null;
        });
      },
      galleryFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.gallery);
        setState(() { productNetworkImage = null; });
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
    final size = MediaQuery.of(context).size;
    return LoadingManager(
      isLoading: _isLoading,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          bottomSheet: SizedBox( //dodavanje 2 gumba na dno stranice (clear i upload)
            height: kBottomNavigationBarHeight + 10,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.clear),
                    label: const Text(
                      "Clear",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      clearForm();
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      // backgroundColor: Colors.red
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (isEditing) {
                        _editProduct();
                      }else {
                      _uploadProduct();
                      }
                    },
                    icon: const Icon(Icons.upload),
                    label: Text(
                      isEditing ? "Edit product" : "Upload a new product",
                    ),
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            centerTitle: true,
            title: TitlesTextWidget(
            label: isEditing ? "Edit product" : "Upload a new product",
              ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
    
                  //Image Picker
    
                if (isEditing && productNetworkImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      productNetworkImage!,
                      // width: size.width * 0.7,
                      height: size.width * 0.5,
                      alignment: Alignment.center,
                    ),
                  )
                ]
                else if (_pickedImage == null)...{
                    SizedBox(
                    width: size.width * 0.4 + 10,
                    height: size.width * 0.4,
                    child: DottedBorder(
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                            Icons.image_outlined,
                            size: 80,
                            color: Colors.blue,
                            ),
                            TextButton(
                              onPressed: () {
                                localImagePicker();
                              },
                              child: const Text("Pick Product Image"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  } else ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(
                            _pickedImage!.path,
                          ),
                          // width: size.width * 0.7,
                          height: size.width * 0.5,
                          alignment: Alignment.center,
                        ),
                      )
                    ],
    
                    // ako prostor za sliku nije prazan tada će se prikazati dva polja koja daju dvije navedene opcije
                    if (_pickedImage != null || productNetworkImage != null)...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              localImagePicker();
                            },
                            child: const Text("Pick another image"),
                          ),
                          TextButton(
                            onPressed: () {
                              removePickedImage();
                            },
                            child: const Text(
                              "Remove image",
                              style: TextStyle(color: Colors.red),
                              ),
                              
                          ),
                        ],
                      )
                    ],
    
                  const SizedBox(
                    height: 25,
                  ),
    
                  // Category dropdown widget
                  DropdownButton(
                    items: AppConstants.categoriesDropdownList,
                    value: _categoryValue, // value prosljedujemo kako bi nakon odabira kategorije ostalo pisati koju smo kategoriju odabrali u polju za odabir kategorija
                    hint: Text("Choode a category"),
                    onChanged: (String? value) {
                      setState(() {
                        _categoryValue = value;
                      });
                    }
                    ),
    
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            key: const ValueKey("Title"),
                            maxLength: 80,
                            maxLines: 2,
                            minLines: 1,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              hintText: 'Product Title',
                            ),
                            validator: (value) { // validator provjerava jeli polje ostalo prazno ako je onda šalje sljedeću poruku
                              return MyValidators.uploadProdTexts(
                                value: value,
                                toBeReturnedString: "Please enter a valid title",
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  controller: _priceController,
                                  key: const ValueKey("Price \$"),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^(\d+)?\.?\d{0,2}'),
                                    ),
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: 'Price',
                                    prefix: SubtitleTextWidget(
                                      label: "\$ ",
                                      color: Colors.blue,
                                      fontSize: 16,
                                    ),
                                  ),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString: "Price is missing",
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  key: const ValueKey('Quantity'),
                                  decoration: const InputDecoration(
                                    hintText: 'Qty'
                                  ),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString: "Quantity is missing"
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                            ),
                            TextFormField(
                              key: const ValueKey('Discription'),
                              controller: _descriptionController,
                              minLines: 5,
                              maxLines: 8,
                              maxLength: 1000,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                hintText: 'Product description',
                              ),
                              validator: (value) {
                                return MyValidators.uploadProdTexts(
                                  value: value,
                                  toBeReturnedString: "Description is missed",
                                );
                              },
                              onTap: () {
                                
                              },
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
        ),
      ),
    );
  }
}