const mongoose = require('mongoose')
const Schema = mongoose.Schema

const orderSchema = new Schema({
    hash: {type: String, required: true},
    dateIssued: {type: String, required: true}, 
    businessName: {type: String, required: true}, 
    businessAddress: {type: Object, required: true},
    businessPhone: {type: String, required: true},
    subtotal: {type: Number, required: true}, 
    total: {type: Number, required: true},
    orderInfo: {type: Object, required: true}
},
{
    timestamps: true
})

const Order = mongoose.model("Order", orderSchema)

module.exports = Order