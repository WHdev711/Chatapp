const functions = require('firebase-functions')
const admin = require('firebase-admin')
admin.initializeApp()

exports.sendNotification = functions.firestore
    .document('chatRooms/{groupId1}/chats/{message}')
    .onCreate((snap, context) => {
        console.log('----------------start function--------------------')
        console.log("hello this is log start")

        const doc = snap.data()
        console.log("hello this is log")
        console.log(doc)
        console.log("hello this is log end")

        const idFrom = doc.idFrom
        const idTo = doc.idTo
        const contentMessage = doc.message

        // Get push token user to (receive)
        admin
            .firestore()
            .collection('users')
            .where('uid', '==', idTo)
            .get()
            .then(querySnapshot => {
                querySnapshot.forEach(userTo => {
                    console.log(`Found user to: ${userTo.data().name}`)
                    console.log(`Found user pushtoken to: ${userTo.data().pushToken}`)
                    if (userTo.data().pushToken && userTo.data().chattingWith !== idFrom) {
                        // Get info user from (sent)
                        admin
                            .firestore()
                            .collection('users')
                            .where('uid', '==', idFrom)
                            .get()
                            .then(querySnapshot2 => {
                                querySnapshot2.forEach(userFrom => {
                                    console.log(`Found user from: ${userFrom.data().name}`)
                                    const payload = {
                                        notification: {
                                            title: `You have a message from "${userFrom.data().name}"`,
                                            body: contentMessage,
                                            badge: '1',
                                            sound: 'default'
                                        }
                                    }
                                    // Let push to the target device
                                    admin
                                        .messaging()
                                        .sendToDevice(userTo.data().pushToken, payload)
                                        .then(response => {
                                            console.log('Successfully sent message:', response)
                                        })
                                        .catch(error => {
                                            console.log('Error sending message:', error)
                                        })
                                })
                            })
                    } else {
                        console.log('Can not find pushToken target user')
                    }
                })
            })
        return null
    })