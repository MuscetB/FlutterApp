import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:projekt_webshop/consts/validator.dart';
import 'package:projekt_webshop/root_screen.dart';
import 'package:projekt_webshop/screens/auth/forgot_password.dart';
import 'package:projekt_webshop/screens/auth/register.dart';
import 'package:projekt_webshop/screens/loading_manager.dart';
import 'package:projekt_webshop/services/my_app_functions.dart';
import 'package:projekt_webshop/widgets/app_name_text.dart';
import 'package:projekt_webshop/widgets/auth/google_button.dart';
import 'package:projekt_webshop/widgets/subtitle_text.dart';
import 'package:projekt_webshop/widgets/title_text.dart';

class LoginScreen extends StatefulWidget {
  static const routName = '/LoginScreen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// LoginScreenState je pripadajuća State klasa koja sadrži varijable za praćenje stanja forme,
//fokusa polja, kontrolera teksta i indikatora učitavanja, te instancu FirebaseAuth za autentikaciju korisnika.
class _LoginScreenState extends State<LoginScreen> {
  bool obscureText = true;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;

  final _formkey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    // Focus Nodes
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    super.initState();
    
  }

  @override
  void dispose() {
    if(mounted){
      _emailController.dispose();
      _passwordController.dispose();
    // Focus Nodes
      _emailFocusNode.dispose();
      _passwordFocusNode.dispose();
    }
    super.dispose();
  }
  Future<void> _loginFct() async {
    final isValid = _formkey.currentState!.validate(); //provjera polja za tekst
    FocusScope.of(context).unfocus();

  // ovo koristimo za baratanje grešaka??
    if(isValid) {
      try{
        setState(() {
          _isLoading = true;
        });
        
      await auth.signInWithEmailAndPassword( // s ovim dopuštamo korisnicima da se registriraju
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ); // ako postoji greška kod prestaje ovdje i ovo ispod neće biti odrađeno nego preskače na catch blok
      Fluttertoast.showToast( // kod do dna sa pub dev primjera za flutter toast proširenje
        msg: "Login Succeful",
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

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(
                    height: 60,
                    ),
        
                    // TEXT WIDGEET NASLOVA
                  const AppNameTextWidget(
                    fontSize: 30,
                    ),
                  const SizedBox(
                    height: 60,
                    ),
        
                    // TEXT
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: TitlesTextWidget(
                      label: "Welcome back!"
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                    ),
                  Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        
                        //  EMAIL POLJE ZA UNOS
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "Email address",
                            prefixIcon:  Icon(
                              IconlyLight.message,
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(_passwordFocusNode);
                          },
                          validator: (value) { // poruka ispod polja za email koja se javlja ako je polje ostalo prazno
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
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: obscureText,
                          decoration:  InputDecoration(
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
                            hintText: "**********",
                            prefixIcon: const Icon(
                              IconlyLight.lock,
                            ),
                          ),
                          onFieldSubmitted: (value) async{
                            await _loginFct();
                          },
                           validator: (value) { // poruka ispod polja za lozinku koja se javlja ako je polje ostalo prazno
                            return MyValidators.passwordValidator(value);
                          }
                        ),
                        const SizedBox(
                          height: 16,
                        ),
        
                        // FORGOT PASSWORD TEXTBUTTON
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                ForgotPasswordScreen.routeName,
                              );
                            },
                            child: const SubtitleTextWidget(
                              label: "Forgot password?",
                              fontStyle: FontStyle.italic,
                              textDecoration: TextDecoration.underline,
                              ),
                            ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
        
                        // LOGIN BUTTON
                        SizedBox(
                          width: double.infinity, //proširiva ikonu logina preko cijele širine ekrana
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(12.0),
                              // backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          icon: const Icon(Icons.login),
                          label: const Text("Login"),
                          onPressed: () async{
                              await _loginFct();
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
        
                        // TEXT
                        SubtitleTextWidget(label: "Or connect using".toUpperCase(),),
                        const SizedBox(
                          height: 16,
                        ),
        
                        // GUEST AND GOOGLE CONNECTION
                        SizedBox(
                          height: kBottomNavigationBarHeight + 10,
                          child: Row(
                            children: [
                            const Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: kBottomNavigationBarHeight,
                                child: FittedBox(
                                  child: GoogleButton())
                                ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: SizedBox(
                                height: kBottomNavigationBarHeight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(12.0),
                                    // backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: const Text("Guest?"),
                                  onPressed: () async{
                                    Navigator.of(context)
                                  .pushNamed(RootScreen.routName);
                                    },
                                  ),
                                ),
                            ),
                            ]
                          ,),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
        
                        // TEXT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SubtitleTextWidget(
                              label: "New here?"
                            ),
                            TextButton(
                            child: const SubtitleTextWidget(
                              label: "Sing up?",
                              fontStyle: FontStyle.italic,
                              textDecoration: TextDecoration.underline,
                              ),
                              onPressed: () {
                                Navigator.of(context)
                                  .pushNamed(RegisterScreen.routName);
                              },
                            ),
                          ],
                        )
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