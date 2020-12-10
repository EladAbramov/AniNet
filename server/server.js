const express = require('express');
const mongoose = require("mongoose");
var jwt = require('jsonwebtoken');

const app = express();
const port = 5000;

// Function to connect to mongodb
async function connectDB(){
    await mongoose.connect("mongodb+srv://auth1:NIaDEoqcSjw4t2on@cluster0.fbeoz.mongodb.net/aninet", { useNewUrlParser: true, useUnifiedTopology: true });
    console.log("Successfully connected to database");
}

connectDB();

// Model
const schema = new mongoose.Schema({ email: 'string', password: 'string' });
const User = mongoose.model('User', schema);

// This take the post body
app.use(express.json({ extended: false }));

// Home route
app.get('/', (req, res) => {
    res.send('Hello World!')
});

// SignUp route
app.post('/signup', async (req, res) => {
    const { email, password } = req.body;
    let userCheck = await User.findOne({email});
    if(userCheck) {
        return res.json({msg: "This email is already taken"});
    }
    let user = new User({
        email,
        password
    });
    await user.save();
    var token = jwt.sign({ id: user.id }, "password");
    res.json({token: token});
});

// Login route
app.post('/login', async (req, res) => {
    const { email, password } = req.body;
    let user = await User.findOne({email});
    if(!user) {
        return res.json({msg: "No user found with that email"});
    }
    if(user.password !== password) {
        return res.json({msg: "Password is not correct"});
    }
    var token = jwt.sign({ id: user.id }, 'password');
    return res.json({token: token});
});

// Private route
app.get('/private', async (req, res) => {
    let token = req.header("token");
    if(!token){
        return res.json({msg: "This is a private route"});
    }
    var decoded = jwt.verify(token, "password");
    console.log(decoded.id);
});

app.listen(port, () => {
    console.log(`Example app listening at http://localhost:${port}`)
});