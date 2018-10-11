exec = require('child_process').exec
fs = require('fs')

execSettings = {encoding: 'binary', maxBuffer: 100000*1024}

defaultConvert = 'pdf:png'

convertSettings =
	'pdf:jpg':
		'input': 'pdf'
		'output': 'jpg'
		'args': '-density 600'
	'pdf:png':
		'input': 'pdf'
		'output': 'png'
		'args': '-density 600'
	'pdf:png-thumb':
		'input': 'pdf'
		'output': 'png'
		'args': '-depth 4 -resize 173 -quality 80 -strip'

# function to encode file data to base64 encoded string
base64_encode = (file) ->
     # read binary data
    bitmap = fs.readFileSync(file)
     # convert binary data to base64 encoded string
    return new Buffer(bitmap).toString('base64')

getConvertSettings = (req) ->
	b = req.body
	if b.convert
		res = convertSettings[b.convert]
		res.input = b.input if b.input
		res.output = b.output if b.output
		res.args = b.args if b.args
		return res
	else
		convertSettings[defaultConvert]


exports.convert = (req, res) ->
	upload = req.files.upload

	console.log(upload)

	settings = getConvertSettings(req)

	res.type(settings.output)

	cmd = "convert #{settings.input}:#{upload.path} #{settings.args} #{settings.output}:-"

	exec(cmd, execSettings, (error, stdout, stderr) ->
		binaryFile = new Buffer(stdout, 'binary')

		console.log("FILE", binaryFile)
		console.log("base64", base64_encode(binaryFile))

		res.send(base64_encode(binaryFile))
	)
