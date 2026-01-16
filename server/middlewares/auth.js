const jwt = require('jsonwebtoken')

const auth = async (req,res, next)=>{
    try{
        const token = req.header("x-auth-token");
        if(!token){
            return res.status(401).json({msg:'No token found. Please login again'});
        }

        const verified = jwt.verify(token, 'passwordKey');

        if(!verified)
            return res.status(401).json({msg:'Unauthorized! Please login'});

        req.user = verified.id ;
        req.token = token ;
        next();
    }catch(e){
        return res.status(500).json({msg:e.message}) ;
    }
}

module.exports = auth