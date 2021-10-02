const mongoose = require('mongoose')
const Schema = mongoose.Schema

const userSchema = new Schema({
    name: {type: String, required: true}, 
    subscriptions: {type: Object, required: true},
    businessList: {type: Object, required: true},
    allReceipts: {type: Object, required: true}
},
{
    timestamps: true
})

const User = mongoose.model("User", userSchema)

module.exports = User