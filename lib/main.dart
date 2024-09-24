import 'package:flutter/material.dart';
import 'package:cloudipsp_mobile/cloudipsp_mobile.dart';
import 'package:cloudipsp_mobile/src/cloudipsp_web_view_confirmation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloudipsp Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Cloudipsp _cloudipsp;
  bool _isApplePaySupported = false;
  bool _isGooglePaySupported = false;

  @override
  void initState() {
    super.initState();
    _cloudipsp = Cloudipsp(1396424, _webViewHolder);
    _checkPaymentMethodsSupport();
  }

  void _webViewHolder(CloudipspWebViewConfirmation confirmation) {
    // Check if the confirmation is of the expected type
    if (confirmation is PrivateCloudipspWebViewConfirmation) {
      // Show the Cloudipsp WebView
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CloudipspWebView(
            key: UniqueKey(),
            confirmation: confirmation,
          ),
        ),
      );
    }
  }

  Future<void> _checkPaymentMethodsSupport() async {
    try {
      final bool applePaySupported = await _cloudipsp.supportsApplePay();
      final bool googlePaySupported = await _cloudipsp.supportsGooglePay();

      setState(() {
        _isApplePaySupported = applePaySupported;
        _isGooglePaySupported = googlePaySupported;
      });
    } catch (e) {
      print('Error checking payment methods: $e');
    }
  }

  Future<void> _payWithApplePay() async {
    final order = Order(
      1000,
      'GEL',
      'unique_order_id',
      'Test payment',
      'customer@example.com',
    );
    try {
      final receipt = await _cloudipsp.applePay(order);
      print('Payment successful: $receipt');
    } catch (e) {
      print('Apple Pay error: $e');
    }
  }

  Future<void> _payWithGooglePay() async {
    void _showPaymentSuccessDialog(Receipt receipt) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Payment Successful'),
              content: Text('Receipt: ${receipt.toString()}'), // Customize this as needed
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      }
    final order = Order(
      1000,
      'GEL',
      'unique_order_id4',
      'Test payment',
      'customer@example.com',
    );
    try {
      final receipt = await _cloudipsp.googlePay(order);
      Navigator.of(context).pop(); // Or any method to close the WebView
      _showPaymentSuccessDialog(receipt);
      print('Payment successful: $receipt');
    } catch (e) {
      print('Google Pay error: $e');
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cloudipsp Payment Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isApplePaySupported)
              ElevatedButton(
                onPressed: _payWithApplePay,
                child: Text('Pay with Apple Pay'),
              ),
            if (_isGooglePaySupported)
              ElevatedButton(
                onPressed: _payWithGooglePay,
                child: Text('Pay with Google Pay'),
              ),
            if (!_isApplePaySupported && !_isGooglePaySupported)
              Text('Neither Apple Pay nor Google Pay are supported on this device.'),
          ],
        ),
      ),
    );
  }
}
