
const functions = require('firebase-functions');
const admin = require('firebase-admin');


admin.initializeApp();


exports.notificacionesAcedis = functions.https
    .onCall(async (data, context) => {

        var tokensCedis = [];

        const extraerTokens = await admin.firestore().collection(data.oficina)
                                                     .doc('cedis')
                                                     .collection('codigos')
                                                     .get();
        
        for(var tooken of extraerTokens.docs){
            tokensCedis.push(tooken.data().token);
        }

        var payload = {
            notification: {
                title: 'Nuevo Pedido',
                body: data.negocio + ' hizo un pedido',
                sound: 'default'
            },
            data: { click_action: 'FLUTTER_NOTIFICATION_CLICK' }
        };

        console.log('todo biene' + data.oficina + data.negocio);

        return admin.messaging().sendToDevice(tokensCedis, payload);

    });
