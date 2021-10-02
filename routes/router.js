const express = require('express')
const router = express.Router()
const Order = require("../models/order.model")
const User = require("../models/user.model")
const Business = require("../models/business.model")
var Chance = require('chance')
const chance = new Chance()
const SECURITY_CODE = "A3D263103C27E77EF8B6267C051906C0"


router.route('/createNewUser').post((req, res) => {
    const securityCode = req.body.securityCode
    if(securityCode != SECURITY_CODE) {
        res.json({success: false, message: "Invalid Credentials"})
        return
    }
    const name = req.body.name
    const newUser = new User({name, pastOrders: [], subscriptions: [], businessList: []})
    newUser.save()
        .then(() => res.json({success:true, message: "New User Created!"}))
        .catch(err => res.json(err))
})

router.route('/createNewBusiness').post((req, res) => {
    const securityCode = req.body.securityCode
    if(securityCode != SECURITY_CODE) {
        res.json({success: false, message: "Invalid Credentials"})
        return
    }
    const businessName = req.body.businessName
    const newBusiness = new Business({businessName, allMessages: []})
    newBusiness.save()
        .then(() => res.json({success:true, message: "New Business Created!"}))
        .catch(err => res.json(err))
})
router.route('/createHash').post((req, res) => {
    const securityCode = req.body.securityCode
    if(securityCode != SECURITY_CODE) {
        res.json({success: false, message: "Invalid Credentials"})
        return
    }
    const hash = chance.string({length: 20})
    const dateIssued = req.body.date
    const businessName = req.body.businessName
    const businessAddress = req.body.businessAddress
    const businessPhone = req.body.businessPhone
    const subtotal = req.body.subtotal
    const total = req.body.total
    const orderInfo = req.body.order

    const newOrder = new Order({hash, dateIssued, businessName, businessAddress, 
            businessPhone, subtotal, total, orderInfo})

    newOrder.save()
        .then(() => res.json({success:true, message: "Order Hash Created!", orderHash: hash}))
        .catch(err => res.json(err))
})

router.route('/retrieveHash').post((req, res) => {
    const securityCode = req.body.securityCode
    if(securityCode != SECURITY_CODE) {
        res.json({success: false, message: "Invalid Credentials"})
        return
    }
    const hash = req.body.hashCode
    const name = req.body.name
    Order.find({hash})
        .then(data => {
            if (data.length == 0) {
                res.json({success: false, message: "No Order Hash Exists"})
                return
            }
            User.find({name})
                .then(us => {
                    const busList = us[0].businessList
                    if (!busList.includes(data[0].businessName)) {
                        us[0].businessList = [...busList, data[0].businessName]
                        console.log(us[0].businessList)
                    }
                    us[0].save()
                        .then(() => res.json({success: true, message: "Order Hash Found", data: data[0]}))
                        .catch(err => res.json(err))
                })
                .catch(err => res.json(err))
        })
        .catch(err => res.json(err))
})

router.route('/addSubscription').post((req, res) => {
    const securityCode = req.body.securityCode
    if(securityCode != SECURITY_CODE) {
        res.json({success: false, message: "Invalid Credentials"})
        return
    }

    const name = req.body.name
    const newSubscription = req.body.subscription

    User.find({name})
        .then(data => {
            if (data.length == 0) {
                res.json({success: false, message: "User Not Found"})
                return
            }
            const currSubscriptions = data[0].subscriptions
            const newList = [...currSubscriptions, newSubscription]
            data[0].subscriptions = newList
            data[0].save()
                .then(res.json({success: true, message: "Subscription Added"}))
                .catch(err => res.json(err))
        })
})

router.route('/getSubscriptions').post((req, res) => {
    const securityCode = req.body.securityCode
    if(securityCode != SECURITY_CODE) {
        res.json({success: false, message: "Invalid Credentials"})
        return
    }

    const name = req.body.name

    User.find({name})
        .then(data => {
            if(data.length == 0) {
                res.json({success: false, message: "User Not Found"})
                return
            }
            res.json({success: true, message: "Retrieved All Subscriptions", subscriptions: data[0].subscriptions})
        })
        .catch(err => res.json(err))
})

router.route('/getBusinessList').post((req, res) => {
    const securityCode = req.body.securityCode
    if(securityCode != SECURITY_CODE) {
        res.json({success: false, message: "Invalid Credentials"})
        return
    }

    const name = req.body.name

    User.find({name})
        .then(data => {
            if(data.length == 0) {
                res.json({success: false, message: "User Not Found"})
                return
            }
            res.json({success: true, message: "Retrieved Business List", businessList: data[0].businessList})
        })
        .catch(err => res.json(err))
})

router.route('/createMessage').post((req, res) => {
    const securityCode = req.body.securityCode
    if(securityCode != SECURITY_CODE) {
        res.json({success: false, message: "Invalid Credentials"})
        return
    }

    const businessName = req.body.businessName
    const newMessage = req.body.message

    Business.find({businessName})
        .then(data => {
            if (data.length == 0) {
                res.json({success: false, message: "Business Not Found"})
                return
            }
            const currMessages = data[0].allMessages
            const newList = [newMessage, ...currMessages]
            data[0].allMessages = newList
            data[0].save()
                .then(res.json({success: true, message: "New Message Sent"}))
                .catch(err => res.json(err))
        })
})

router.route('/retrieveMessages').post((req, res) => {
    const securityCode = req.body.securityCode
    if(securityCode != SECURITY_CODE) {
        res.json({success: false, message: "Invalid Credentials"})
        return
    }
    var newMessages = []

    const name = req.body.name
    
    User.find({name})
        .then(data => {
            if (data.length == 0) {
                res.json({success: false, message: "User Not Found"})
                return
            }
            const currSubscriptions = data[0].subscriptions
            currSubscriptions.forEach((sub, i) => {
                Business.find({businessName: sub})
                    .then(foundB => {
                        if (foundB.length != 0) {
                            newMessages = [...newMessages, ...foundB[0].allMessages]
                            if (i == currSubscriptions.length - 1) {
                                newMessages.sort((message1, message2) => new Date(message2.date) - new Date(message1.date))
                                res.json({success: true, message: "Messages Aggregated", messageData: newMessages})
                            }
                        }
                    })
            })
        })
        .catch(err => res.json(err))
})


router.route('/')
module.exports = router
