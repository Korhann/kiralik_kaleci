const express = require('express');
const Iyzipay = require('iyzipay');

const app = express();
app.use(express.json());

const iyzipay = new Iyzipay({
  apiKey: 'qcEfRXmHiUVZyO76OH7U3FT6MR6gBi2p',
  secretKey: 'NddUCV45JbJVWqaUX3UlIq30rZtjJIMV',
  uri: 'https://api.iyzipay.com'
});

app.post('/checkout-form', async (req, res) => {
  const { name, surname, email, phone, ip, price, sellerId, sellerDocId, buyerId} = req.body;

  if (!name || !surname || !email || !phone || !ip || !price || !sellerId || !sellerDocId || !buyerId) {
    return res.status(400).send({ error: 'Missing required fields' });
  }

  const formattedPrice = Number(price).toFixed(2);

  const request = {
    locale: Iyzipay.LOCALE.TR,
    conversationId: sellerId,
    price: formattedPrice,
    paidPrice: formattedPrice,
    currency: Iyzipay.CURRENCY.TRY,
    basketId: sellerDocId,
    paymentGroup: Iyzipay.PAYMENT_GROUP.PRODUCT,
    callbackUrl: "https://senin-domainin.com/iyzico-callback",

    buyer: {
      id: buyerId,
      name,
      surname,
      gsmNumber: phone,
      email,
      identityNumber: '11171114128',
      registrationAddress: 'Adres',
      ip,
      city: 'Istanbul',
      country: 'Turkey',
      zipCode: '34000'
    },

    shippingAddress: {
      contactName: `${name} ${surname}`,
      city: 'Istanbul',
      country: 'Turkey',
      address: 'Adres',
      zipCode: '34000'
    },

    billingAddress: {
      contactName: `${name} ${surname}`,
      city: 'Istanbul',
      country: 'Turkey',
      address: 'Adres',
      zipCode: '34000'
    },

    basketItems: [
      {
        id: 'BI101',
        name: 'Service Payment',
        category1: 'Goalkeeper',
        category2: 'Rental',
        itemType: Iyzipay.BASKET_ITEM_TYPE.VIRTUAL,
        price: formattedPrice
      }
    ]
  };

  iyzipay.checkoutFormInitialize.create(request, function (err, result) {
    if (err) {
      return res.status(500).send({ error: 'Checkout form error', details: err });
    }
    res.status(200).send(result);
  });

});

module.exports = app;