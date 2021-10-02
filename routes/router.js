const express = require('express')
const router = express.Router()
const Order = require("../models/order.model")
var Chance = require('chance')
const chance = new Chance()
const SECURITY_CODE = "A3D263103C27E77EF8B6267C051906C0"

router.route('/createHash').post((req, res) => {
    const securityCode = req.body.securityCode
    if(securityCode != SECURITY_CODE) {
        res.json({success: false, message: "Invalid Credentials"})
        return
    }
    const hash = chance.string({length: 20})
    
    const name = req.body.name

    const newOrder = new Order({hash, name})
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

router.route('/')
module.exports = router
