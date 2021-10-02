const express = require("express")
const mongoose = require("mongoose")
const cors = require("cors")
const path = require("path")
const http = require("http")
require("dotenv").config()

const PORT = process.env.PORT || 5000

const app = express()
const server = http.createServer(app)

app.use(express.json())
app.use(cors())

mongoose.connect(process.env.MONGODB_URI)
const connection = mongoose.connection
connection.once('open', () => {
    console.log('MongoDB connection established')
})

const router = require('./routes/router')

app.use(router)

server.listen(PORT, () => {
    console.log(`Server is running on port: ${PORT}`)
})
