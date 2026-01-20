const cors = require('cors');
const express = require("express");
const mongoose = require("mongoose");
const http = require('http');
const authRouter = require("./routes/auth");
const documentRouter = require("./routes/document");
const Document = require('./models/document');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(authRouter);
app.use(documentRouter) ;

var server = http.createServer(app);
var io = require("socket.io")(server, {
    cors: {
    origin: "*",  // Allow all origins (or specify your client IP)
    methods: ["GET", "POST"],
    credentials: true
  }
});
//MONGOOSE CONNECT
const uri = "mongodb+srv://najmuschy12:ramim121215@docsclone.npmqul2.mongodb.net/?appName=docsclone";
const clientOptions = { tls : true, serverApi: { version: '1', strict: true, deprecationErrors: true } };
async function run() {
  try {
    // Create a Mongoose client with a MongoClientOptions object to set the Stable API version
    await mongoose.connect(uri, clientOptions).then(()=>{
        console.log('connection succesful');
    }).catch((err) => {
        console.log(err)
    })
    await mongoose.connection.db.admin().command({ ping: 1 });
    console.log("Pinged your deployment. You successfully connected to MongoDB!");
  } catch(e){
    
  }
}
run().catch(console.dir);
//MONGOOSE


const PORT = process.env.PORT || 3001 ;

io.on('connection', (socket)=>{
    console.log('Client connected:', socket.id); 
    socket.on('join', (documentId)=>{
        socket.join(documentId);
        console.log('connection succesful');
    })

    socket.on('typing', (data)=>{
        socket.broadcast.to(data.room).emit("change", data) ;
        // console.log(`Typing event from ${socket.id} in room ${data.room}`); // ✅ Add logging
    })
    socket.on('save', (data)=>{
        saveData(data);
    })
})

const saveData = async(data)=>{
    let document = await Document.findById(data.room);
    document.content = data.delta; 
    document = await document.save();
}

server.listen(PORT, "0.0.0.0", ()=>{
    console.log(`connected at port ${PORT}`)

})