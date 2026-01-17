const cors = require('cors');
const express = require("express");
const mongoose = require("mongoose");
const http = require('http');
const authRouter = require("./routes/auth");
const documentRouter = require("./routes/document");

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(authRouter);
app.use(documentRouter) ;

var server = http.createServer(app);
var io = require("socket.io")(server);
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
    console.log('connected'+socket.id) ;
})
app.listen(PORT, "0.0.0.0", ()=>{
    console.log(`connected at port ${PORT}`)

})