const express = require('express');
const auth = require('../middlewares/auth');
const Document = require('../models/document');
const documentRouter = express.Router();

documentRouter.post('/doc/create', auth, async (req, res)=>{
    try{
    const {createdAt} = req.body ;
    let document = new Document({
        uid : req.user,
        title : 'Untitled Document',
        createdAt
    })

    document =await document.save();
    res.json(document);
    }catch(e){
        res.status(500).json({error: e.message}) ;
    }

})

documentRouter.get('/docs/me', auth, async(req,res)=>{
    try{
        let documents = await Document.find({uid : req.user});
        console.log(req.body);
        res.json({documents});

    }catch(e){
        res.status(500).json({error: e.message});
    }

})

documentRouter.post('/doc/updateTitle', auth, async(req, res)=>{
    try {
        const {id, title} = req.body
        let document = await Document.findByIdAndUpdate(id, {title},{new:true})

        res.json({document})
    } catch (e) {
        res.status(500).json({error: e.message})
    }
})
documentRouter.get('/doc/:id', auth, async(req, res)=>{
    try {
        let document = await Document.findById(req.params.id);
        res.json({document})
    } catch (e) {
        res.status(500).json({error:e.message})
    }
})

module.exports= documentRouter
