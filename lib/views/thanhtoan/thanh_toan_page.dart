import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_trangsuc_vs2/views/thanhtoan/tb_thanh_to%C3%A1n_tc.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool savePaymentInfo = true;
  bool isCardValid = false;
  bool isAddressValid = false;
  String _paymentMethod = 'visa'; // Biến để lưu phương thức thanh toán

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController postalController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountNameController = TextEditingController();

  void checkFormValidity() {
    setState(() {
      isCardValid = cardNumberController.text.length >= 16 &&
          expiryController.text.isNotEmpty &&
          cvcController.text.length == 3;

      isAddressValid = addressController.text.isNotEmpty &&
          cityController.text.isNotEmpty &&
          postalController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    cardNumberController.addListener(checkFormValidity);
    expiryController.addListener(checkFormValidity);
    cvcController.addListener(checkFormValidity);
    addressController.addListener(checkFormValidity);
    cityController.addListener(checkFormValidity);
    postalController.addListener(checkFormValidity);
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    expiryController.dispose();
    cvcController.dispose();
    addressController.dispose();
    cityController.dispose();
    postalController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    accountNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Payment Method Selection
            RadioListTile<String>(
              value: 'bank_transfer',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
              title: const Text("Chuyển Khoản"),
            ),
            RadioListTile<String>(
              value: 'visa',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
              title: Row(
                children: [
                  Image.asset('assets/images/visa.jpg', width: 40), // Icon Visa
                  const SizedBox(width: 10),
                  const Text("Thẻ Visa"),
                ],
              ),
            ),

            // Card Details Input (Hiển thị khi chọn Thẻ Visa)
            if (_paymentMethod == 'visa') ...[
              TextField(
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Card number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expiryController,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(5),
                        _CardExpiryInputFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: "MM / YY",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: cvcController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(3),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: "CVC",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Bank Transfer Details Input (Hiển thị khi chọn Chuyển Khoản)
            if (_paymentMethod == 'bank_transfer') ...[
              TextField(
                controller: bankNameController,
                decoration: const InputDecoration(
                  labelText: "Tên ngân hàng",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: accountNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Số tài khoản",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: accountNameController,
                decoration: const InputDecoration(
                  labelText: "Tên chủ tài khoản",
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            // Save payment info
            CheckboxListTile(
              value: savePaymentInfo,
              onChanged: (value) {
                setState(() {
                  savePaymentInfo = value!;
                });
              },
              title: const Text("Save my payment info"),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            const SizedBox(height: 20),
            const Text(
              "Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Address Inputs
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Address line 1",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: "Apt, unit, suite, etc. (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: "City / Town / Village",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: postalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Postal code",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // Order Summary
            ListTile(
              leading: Image.asset('assets/images/sp_1.jpg', width: 60),
              title: const Text(
                "Glapex - 3D Glass Polygonal Abstract Shapes Collection",
                style: TextStyle(fontSize: 14),
              ),
              subtitle: const Text("3 US\$ one-time payment"),
            ),
            const SizedBox(height: 10),

            // Price Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Subtotal"),
                Text("3.00 US\$"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("VAT/GST"),
                Text("0.00 US\$"),
              ],
            ),
            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("3.00 US\$", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // Complete Purchase Button
            ElevatedButton(
              onPressed: (isCardValid && isAddressValid)
                  ? () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => PaymentSuccessScreen()), // Chuyển đến trang xác nhận
                      );
                    }
                  : null, // Nếu thông tin chưa hợp lệ, nút sẽ bị vô hiệu hóa
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Complete Purchase"),
            ),

            const SizedBox(height: 10),
            const Text(
              "By purchasing, you agree to the Terms of Service.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ **Định dạng đầu vào cho trường MM/YY**
class _CardExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.length == 2 && !text.contains('/')) {
      return TextEditingValue(
        text: '$text/',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }
    return newValue;
  }
}