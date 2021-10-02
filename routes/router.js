const express = require('express')
const router = express.Router()
const Order = require("../models/order.model")
const User = require("../models/user.model")
var Chance = require('chance')
const chance = new Chance()
const SECURITY_CODE = "A3D263103C27E77EF8B6267C051906C0"


router.route('/createNewUser').post((req, res) => {
    const name = req.body.name
    const newUser = new User({name, pastOrders: [], subscriptions: [], recievedMessages: []})
    newUser.save()
        .then(() => res.json({success:true, message: "New User Created!"}))
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
    Order.find({hash})
        .then(data => {
            console.log(data)
            if (data.length == 0) {
                res.json({success: false, message: "No Order Hash Exists"})
                return
            }
            res.json({success: true, message: "Order Hash Found", data: data[0]})
        })
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
router.route('/retrieveNewMessages').post((req, res) => {
    const securityCode = req.body.securityCode
    if(securityCode != SECURITY_CODE) {
        res.json({success: false, message: "Invalid Credentials"})
        return
    }
    const newMessages = []
    const subs = req.body.subs
})


router.route('/')
module.exports = router
