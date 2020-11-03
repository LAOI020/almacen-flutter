
const functions = require('firebase-functions');
const admin = require('firebase-admin');


const nodemailer = require('nodemailer');
const { firestore } = require('firebase-admin');


admin.initializeApp();


exports.mandarEmailFinanzas = functions.firestore
    .document('FUNCTIONS/enviarEmailFinanzas/detalles/{docDetalles}')
    .onCreate(async (snapshot, context) => {

        admin.firestore()
            .collection(snapshot.data().oficina)
            .doc('finanzas')
            .get().then(doc => {

                var transporte = nodemailer.createTransport({
                    service: 'gmail',
                    auth: {
                        user: 'enviarexcelfinanzas@gmail.com',
                        pass: 'arjomabelu19' 
                    }
                });

                var opcionesEmail = {
                    from: 'enviarexcelfinanzas@gmail.com',
                    to: doc.data().correo,
                    subject: 'DETALLES PEDIDOS',
                    text: snapshot.data().urlArchivo                    
                }

                transporte.sendMail(opcionesEmail, function(err, info){
                    if(err){
                        console.log('error' + err);
                    } else{
                        console.log('mensaje enviado');
                    }
                });

            })




    })



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
                body: data.negocio + 'hizo un pedido',
                sound: 'default'
            },
            data: { click_action: 'FLUTTER_NOTIFICATION_CLICK' }
        };

        console.log('todo biene' + data.oficina + data.negocio);

        return admin.messaging().sendToDevice(tokensCedis, payload);

    });
