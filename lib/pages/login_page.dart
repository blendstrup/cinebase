// Packages
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
// Models
import '../models/login_model.dart';
// Data
import '../data/firestore_data_parser.dart';
// Screens
import 'home_page.dart';
// Widgets
import '../widgets/text_widgets.dart';
import '../widgets/dialogs.dart';

class LoginModelProvider extends StatefulWidget {
  @override
  _LoginModelProviderState createState() => _LoginModelProviderState();
}

class _LoginModelProviderState extends State<LoginModelProvider> {
  late LoginModel model;

  @override
  void initState() {
    super.initState();
    model = LoginModel();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<LoginModel>(
      model: model,
      child: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _model = ScopedModel.of<LoginModel>(context, rebuildOnChange: false);
    ThemeData theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Cinebase',
                  style: Theme.of(context).textTheme.displayMedium),
              SizedBox(height: 30),
              ScopedModel<LoginModel>(model: _model, child: LoginForm()),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => ScopedModel<LoginModel>(
                    model: _model,
                    child: CreateUserDialog(),
                  ),
                ),
                child: BodyText('Sign Up'),
              ),
              SizedBox(height: 20)
            ],
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeModelProvider(null),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      SubtitleText('Skip login'),
                      SizedBox(height: 5),
                      BodyText(
                        'Enter as guest',
                        color: theme.textTheme.subtitle1!.color!.withAlpha(120),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _loginFormKey = GlobalKey<FormState>();

  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

  final _loginPasswordNode = FocusNode();

  bool _obscureLoginPassword = true;
  bool _loginValidated = false;
  bool _loginValidating = false;

  @override
  void dispose() {
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Form(
            key: _loginFormKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Enter your e-mail adress';
                    } else if (!_loginValidated) {
                      return 'Credentials incorrect';
                    } else {
                      return '';
                    }
                  },
                  controller: _loginEmailCtrl,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onFieldSubmitted: (val) {
                    FocusScope.of(context).requestFocus(_loginPasswordNode);
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  focusNode: _loginPasswordNode,
                  controller: _loginPasswordCtrl,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Enter your password';
                    } else {
                      return '';
                    }
                  },
                  obscureText: _obscureLoginPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: _obscureLoginPassword
                          ? Icon(Icons.visibility_off)
                          : Icon(Icons.visibility),
                      onPressed: () => setState(() {
                        _obscureLoginPassword = !_obscureLoginPassword;
                      }),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_loginValidating)
          CircularProgressIndicator()
        else ...[
          ElevatedButton(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: SubtitleText('Log In'),
            ),
            onPressed: () async {
              setState(() {
                _loginValidating = true;
              });

              User? _user;
              await ScopedModel.of<LoginModel>(context, rebuildOnChange: false)
                  .validateLogin(
                _loginEmailCtrl.text,
                _loginPasswordCtrl.text,
              )
                  .then((result) {
                _loginValidated = result[0];
                _user = result[1];
              });

              if (_loginFormKey.currentState!.validate()) {
                _loginEmailCtrl.clear();
                _loginPasswordCtrl.clear();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeModelProvider(_user),
                  ),
                );
              } else {
                setState(() {
                  _loginValidating = false;
                });
              }
            },
          ),
        ],
      ],
    );
  }
}
