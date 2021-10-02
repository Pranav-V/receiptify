const express = require('express')
const router = express.Router()
const Order = require("../models/order.model")
var Chance = require('chance')
const chance = new Chance()

router.route('/createHash').post((req, res) => {
    const securityCode = req.body.code
    if(securityCode != "applePie") {
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

module.exports = router
