## Flutter tinkoff sdk module 

Main goal of this project is to integrate native Tinkoff Acquiring SDK to my Flutter project using sdk >= 2.0.0

- https://github.com/Tinkoff/AcquiringSdk_IOS - ios sdk
- https://github.com/Tinkoff/tinkoff-asdk-android - android sdk 

**Warning** 
<p>If you want to use method <strong>openPaymentScreen</strong> with parameter paymentId in tinkoffOrderOptions, <br> it is important to use ios sdk version <=2.5.0,
because version 2.8.0 not working (for now).

Example of usage: 

      FlutterTinkoffSdk acquiring = FlutterTinkoffSdk(
        publicKey: _publicKey,
        terminalKey: _terminalKey,
      );

      final response = await acquiring.openPaymentScreen(
        paymentId: _paymentId,
        orderId: _orderId,
        title: _title,
        money: _money,
        customerId: _customerKey,
        email: _customerEmail,
        lang: _languageCode,
      );
      if (response.status == TinkoffAcquiringResultStatus.resultOK) {
        // payment success 
      } else if (response.status == TinkoffAcquiringResultStatus.resultCancelled) {
        // user closed payment screen 
      } else {
       // any payments errors
      }
