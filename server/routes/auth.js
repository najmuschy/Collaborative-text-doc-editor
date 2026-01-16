const express =  require('express') ;
const User = require('../models/user');
const  jwt = require('jsonwebtoken');
const auth = require('../middlewares/auth');


const authRouter = express.Router() ;

authRouter.post('/api/signup', async (req, res)=>{
    try{

        const {name, email, profilePic} = req.body
        let user = await User.findOne({email})
        if(!user){
            user = new User({
                name ,
                email,
                profilePic
            });
            user = await user.save()
        }
        const token = jwt.sign({id:user._id},'passwordKey');
        res.json({user, token}) ;
    }catch(e){
    console.error(e);
        res.status(500).json({ error: 'Internal server error' });
    }
});

authRouter.get('/',auth,async(req,res)=>{
    const user = await User.findById(req.user);
    console.log(user)
    res.json({user, token: req.token});
})


module.exports = authRouter