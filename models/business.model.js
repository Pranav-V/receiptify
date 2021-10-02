const mongoose = require('mongoose')
const Schema = mongoose.Schema

const businessSchema = new Schema({
    businessName: {type: String, required: true}, 
    allMessages: {type: Object, required: true}
},
{
    timestamps: true
})

const Business = mongoose.model("Business", businessSchema)

module.exports = Business