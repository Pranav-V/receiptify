const express = require('express')
const router = express.Router()
const Order = require("../models/order.model")
const User = require("../models/user.model")
const Business = require("../models/business.model")
var Chance = require('chance')
const chance = new Chance()
const nodemailer = require("nodemailer");

const SECURITY_CODE = "A3D263103C27E77EF8B6267C051906C0"


router.route('/createNewUser').post((req, res) => {
    const securityCode = req.body.securityCode
    if(securityCode != SECURITY_CODE) {
        res.json({success: false, message: "Invalid Credentials"})
        return
    }
    const name = req.body.name
    User.find({name})
        .then(data => {
            if (data.length == 0) {
                const newUser = new User({name, pastOrders: [], subscriptions: [], businessList: [], allReceipts:[]})
                newUser.save()
                    .then(() => res.json({success:true, message: "New User Created!"}))
                    .catch(err => res.json(err))
            } else {
                res.json({success: false, message: "Account with name already exists"})
            }
        })
        .catch(err => res.json(err))
    
})

router.route('/createNewBusiness').post((req, res) => {
    const securityCode = req.body.securityCode
    if(securityCode != SECURITY_CODE) {
        res.json({success: false, message: "Invalid Credentials"})
        return
    }
    const businessName = req.body.businessName
    Business.find({businessName})
        .then(data => {
            if (data.length == 0) {
                const newBusiness = new Business({businessName, allMessages: []})
                newBusiness.save()
                    .then(() => res.json({success:true, message: "New Business Created!"}))
                    .catch(err => res.json(err))
            } else {
                ret.json({success: false, message: "Account with name already exists"})
            }
        })
        .catch(err => ret.json(err))
})

router.route('/createHash').post((req, res) => {
    const securityCode = req.body.securityCode
    if(securityCode != SECURITY_CODE) {
        res.json({success: false, message: "Invalid Credentials"})
        return
    }
    const hash = chance.string({length: 20})
    const dateIssued = req.body.dateIssued
    const businessName = req.body.businessName
    const businessAddress = req.body.businessAddress
    const businessPhone = req.body.businessPhone
    const subtotal = req.body.subtotal
    const total = req.body.total
    const orderInfo = req.body.orderInfo
    const couponInfo = req.body.couponInfo

    const newOrder = new Order({hash, dateIssued, businessName, businessAddress, 
            businessPhone, subtotal, total, orderInfo, couponInfo})

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
    const email = req.body.email

    Order.find({hash})
        .then(data => {
            if (data.length == 0) {
                res.json({success: false, message: "No Order Hash Exists"})
                return
            }
            User.find({name})
                .then(us => {
                    if (us.length == 0) {
                        res.json({success: false, message: "User Not Found"})
                        return
                    }
                    const busList = us[0].businessList
                    const recList = us[0].allReceipts
                    if (!busList.includes(data[0].businessName)) {
                        us[0].businessList = [...busList, data[0].businessName]
                    }
                    if (!recList.includes(hash)) {
                        us[0].allReceipts = [hash, ...recList]
                        console.log("here")
                        if (email != null) {
                            var recieptText = "Business: " + data[0].businessName + "\n\n"
                            recieptText += "| Quantity | Description | Price |\n"
                            recieptText += "----------------------------------------------------"
                            
                            data[0].orderInfo.forEach(elem => {
                                var fixed = formatStr(elem)
                                console.log(fixed)
                                recieptText += "\n" + fixed[0] + fixed[1] + fixed[2]
                            })

                            recieptText += "\n----------------------------------------------------\n"

                            let dollarUSLocale = Intl.NumberFormat("en-US", {
                                style: "currency",
                                currency: "USD",
                            });

                            recieptText += "\nSubtotal: " + dollarUSLocale.format(data[0].subtotal);
                            recieptText += "\nTax:      " + dollarUSLocale.format(data[0].total - data[0].subtotal)
                            recieptText += "\nTotal:    " + dollarUSLocale.format(data[0].total)

                            let mailOptions = {
                                from: 'receiptify.bot@gmail.com',
                                to: email,
                                subject: 'Your Reciept @ Receiptify',
                                text: recieptText
                            };

                            let transporter = nodemailer.createTransport({
                                service: 'gmail',
                                auth: {
                                user: 'receiptify.bot@gmail.com',
                                pass: '1693644087%3A'
                                }
                            });

                            transporter.sendMail(mailOptions, function(error, info){
                                if (error) {
                                console.log(error);
                                } else {
                                console.log('Email sent: ' + info.response);
                                }
                            });
                        }
                    }
                    us[0].save()
                        .then(() => res.json({success: true, message: "Order Hash Found", data: data[0]}))
                        .catch(err => res.json(err))
                })
                .catch(err => res.json(err))
        })
        .catch(err => res.json(err))
})

router.route('/retrieveHashBusiness').post((req, res) => {
    const securityCode = req.body.securityCode
    if(securityCode != SECURITY_CODE) {
        res.json({success: false, message: "Invalid Credentials"})
        return
    }
    const hash = req.body.hashCode
    const businessName = req.body.businessName

    Order.find({hash})
        .then(data => {
            if (data.length == 0) {
                res.json({success: false, message: "No Order Hash Exists"})
                return
            }
            if (businessName != data[0].businessName) {
                res.json({scuess: false, message: "Coupon is not Valid"})
                return
            }
            res.json({success: true, message: "Order Hash Found", data: data[0]})
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
            if (!currSubscriptions.includes(newSubscription)) {
                const newList = [...currSubscriptions, newSubscription]
                data[0].subscriptions = newList
            }
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

router.route('/retrieveReceipts').post((req, res) => {
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
            res.json({success: true, message: "Retrieved Receipts", allReceipts: data[0].allReceipts})
        })
        .catch(err => res.json(err))

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


function formatStr(element) {

    var quantity = element.quantity + ""
    var desc = element.name
    var price = element.price + ""


    if (quantity.length > 10) {
        quantity = quantity.substring(0, 7) + "..."
    } else {
        quantity = quantity.padEnd(10)
    }

    desc = " " + desc

    if (desc.length > 18) {
        desc = desc.substring(0, 18) + "..."
    } else {
        desc = desc.padEnd(21)
    }

    price = " $" + price 
    if (price.length > 9) {
        price = price.substring(0, 6) + "..."
    } else {
        price = price.padEnd(9)
    }
    console.log(price)

    return [quantity, desc, price]
}
    

router.route('/')
module.exports = router
