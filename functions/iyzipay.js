// iyzico için (telefon no, ip, isim soyisim, ve email) göndermem gerek sadece (diğerlerini hardcoded olarak gönderebilirim)

const express = require('express');
const Iyzipay = require('iyzipay');

const app = express();
app.use(express.json());

const iyzipay = new Iyzipay({
  apiKey: 'sandbox-uqMvvyPPj6r8KBDPXclVAGoJksUA0els',
  secretKey: 'sandbox-sS6Pr2ejBlxrbE7Uc2TD2lL9CvBQ51ZC',
  uri: 'https://sandbox-api.iyzipay.com'
});


app.post('/', async (req, res) => {
  const { name, surname, email, phone, ip , price} = req.body;

  if (!name || !surname || !email || !phone || !ip || !price) {
    return res.status(400).send({ error: 'Missing required fields' });
  }

  const request = {
    locale: Iyzipay.LOCALE.TR,
    conversationId: '123451789',
    price: price, // Actual price
    paidPrice: '0', // Price with tax/fees
    currency: Iyzipay.CURRENCY.TRY,
    installment: '1',
    basketId: 'B67832',
    paymentChannel: Iyzipay.PAYMENT_CHANNEL.MOBILE,
    paymentGroup: Iyzipay.PAYMENT_GROUP.PRODUCT,
    paymentCard: {
      cardHolderName: name,
      cardNumber: '3428790001700508', // TEST card
      expireMonth: '12',
      expireYear: '2030',
      cvc: '123',
      registerCard: '0'
    },
    buyer: {
      id: 'BY789',
      name,
      surname,
      gsmNumber: phone,
      email,
      identityNumber: '11111111128', // Hardcoded
      lastLoginDate: '2024-05-20 12:00:00',
      registrationDate: '2023-01-01 12:00:00',
      registrationAddress: 'Hardcoded Address',
      ip,
      city: 'Istanbul',
      country: 'Turkey',
      zipCode: '34000'
    },
    shippingAddress: {
      contactName: `${name} ${surname}`,
      city: 'Istanbul',
      country: 'Turkey',
      address: 'Hardcoded Shipping Address',
      zipCode: '34000'
    },
    billingAddress: {
      contactName: `${name} ${surname}`,
      city: 'Istanbul',
      country: 'Turkey',
      address: 'Hardcoded Billing Address',
      zipCode: '34000'
    },
    basketItems: [
      {
        id: 'BI101',
        name: 'Service Payment',
        category1: 'Goalkeeper',
        category2: 'Rental',
        itemType: Iyzipay.BASKET_ITEM_TYPE.VIRTUAL,
        price: '1'
      }
    ]
  };

  iyzipay.payment.create(request, function (err, result) {
    if (err) {
      console.error('Iyzico error:', err);
      return res.status(500).send({ error: 'Payment failed', details: err });
    }

    console.log('Payment success:', result);
    return res.status(200).send(result);
  });
});

module.exports = app;
