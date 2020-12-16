const express = require('express');
const mongoose = require("mongoose");
var jwt = require('jsonwebtoken');

const app = express();
const port = 5000;

// Function to connect to mongodb
async function connectDB(){
    await mongoose.connect(
        "mongodb+srv://auth1:NIaDEoqcSjw4t2on@cluster0.fbeoz.mongodb.net/aninet",
        {
            useNewUrlParser: true,
            useUnifiedTopology: true
        }
    );
    console.log("Successfully connected to database");
}

connectDB();

// Regular user Model
const schema = new mongoose.Schema({
    ownerName: 'string',
    animalName: 'string',
    animalType: 'string',
    videoUrl: 'string',
    email: 'string',
    password: 'string'
});
const User = mongoose.model('User', schema);


// Vet Model
const vetSchema = new mongoose.Schema({ name: 'string', email: 'string', password: 'string' });
const Vet = mongoose.model('Vet', vetSchema);

// This take the post body
app.use(express.json({ extended: false }));

// Home route
app.get('/', (req, res) => {
    res.send('Hello World!')
});


// Sign Up Vet route
app.post('/signupvet', async (req, res) => {
    const { name, email, password } = req.body;
    let vetCheck = await Vet.findOne({email});
    if(vetCheck) {
        return res.json({msg: "This email is already taken"});
    }
    let vet = new Vet({
        name,
        email,
        password
    });
    await vet.save();
    var vetToken = jwt.sign({ id: vet.id }, "pass");
    res.json({vetToken: vetToken});
});
// Login Vet route
app.post('/loginvet', async (req, res) => {
    const { name, email, password } = req.body;
    let vet = await Vet.findOne({email});
    if(!vet) {
        return res.json({msg: "No vet found with that email"});
    }
    if(vet.password !== password) {
        return res.json({msg: "Password is not correct"});
    }
    var vetToken = jwt.sign({ id: vet.id }, "pass");
    return res.json({vetToken: vetToken});
});

// Sign Up User route
app.post('/signup', async (req, res) => {
    const { ownerName, animalName, animalType, videoUrl, email, password } = req.body;
    let userCheck = await User.findOne({email});
    if(userCheck) {
        return res.json({msg: "This email is already taken"});
    }
    let user = new User({
        ownerName,
        animalName,
        animalType,
        videoUrl,
        email,
        password
    });
    await user.save();
    var token = jwt.sign({ id: user.id }, "password");
    res.json({token: token});
});


// Login  User route
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

app.listen(port, () => {
    console.log(`Example app listening at http://localhost:${port}`)
});