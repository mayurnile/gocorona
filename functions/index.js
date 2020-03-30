/* eslint-disable promise/no-nesting */
/* eslint-disable promise/always-return */
/* eslint-disable promise/catch-or-return */
const functions = require('firebase-functions')
const admin = require('firebase-admin')
admin.initializeApp()
/* Listens for new messages added to /messages/:pushId and sends a notification to subscribed users */
exports.pushNotification = functions.database.ref('/admin/{adminID}/{pushId}').onCreate( async (change, context) => {
    console.log('Push notification event triggered');
    /* Grab the current value of what was written to the Realtime Database */
       // var valueObject = event.data.value();
        //console.log(object);
       // console.log(change);
        //console.log(change._data);
        let payload = change._data;
        console.log(payload.data);
        console.log(payload.notification);
        
        //console.log(context);    
       // console.log(object.data.value());
      //  console.log(valueObject);

        //console.log(valueObject.title);

        //console.log(valueObject);
    /* Create a notification and data payload. They contain the notification information, and message to be sent respectively 
        const payload = {
            notification: {
                title: 'App Name',
                body: "New message",    
                sound: "default"
            },
            data: {
                title: valueObject.title,
                message: valueObject.message
            }
        };
    /* Create an options object that contains the time to live for the notification and the priority. */
        const topic = "all";
    return admin.messaging().sendToTopic(topic, payload).then(event => {
        console.log(event);
    }).catch(error => {
        console.log(error);
    });
    });