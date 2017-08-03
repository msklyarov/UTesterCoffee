express      = require 'express'
path         = require 'path'
bodyParser   = require 'body-parser'
routes       = require './server/routes'
pug          = require 'pug'

app          = express()

app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'pug'

#app.set 'view engine', 'ect'
#app.use session
#  cookie: { maxAge: 30 * 24 * 60 * 60 * 1000 }
#  secret: 'react blog sample!!'
#  resave: true
#  saveUninitialized: true

# uncomment after placing your favicon in /public
#app.use(favicon(__dirname + '/public/favicon.ico'));
#app.use logger('dev')
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: false)
app.use express.static(path.join(__dirname, 'public'))

routes.configRoutes app

module.exports = app
