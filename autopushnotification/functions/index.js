const functions = require('firebase-functions');
const admin = require("firebase-admin");
admin.initializeApp();

exports.onNewMessage = functions.firestore
    .document('/users/{userId}/{collID}/{docID}')
    .onCreate(async (snapshot, context) => {

        const userId = context.params.userId;
        const collID = context.params.collID;
        const docID = context.params.docID;
        const chatData = snapshot.data();

        if (collID != 'RecentChats' && collID != 'SavedContacts' && !chatData['sendByMe']) {
            const msgFrom = await admin.firestore().doc(`users/${collID}`).get();

            
            const pushNotificationToken = chatData['pushNotificationToken'];
            if (pushNotificationToken) {
                sendNotification(pushNotificationToken, chatData);
            }
            else {
                console.log("No token for user, can not send notification.")
            }

            function sendNotification(pushNotificationToken, chat) {


                const message =
                {
                    notification:{title: `${msgFrom.data()['displayName']}`,
                    body: `${chat['msg']}`,},
                    token: pushNotificationToken,
                    data: { recipient: collID, doc: docID , click_notification: "FLUTTER_NOTIFICATION_CLICK",
                    },
                };
                admin.messaging().send(message)
                    .then(response => {
                        console.log("Successfully sent message", response);
                    })
                    .catch(error => {
                        console.log("Error sending message", error);
                    })

            }
        }

    });