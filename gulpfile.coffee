gulp        = require 'gulp'
gm        = require 'gulp-gm'
moment      = require 'moment'
fs        = require 'fs'
_         = require 'underscore'
Path        = require 'path'
request     = require 'request'

IMG_RATIO = 1.618

IMG_SRC = 'src/**/*.{gif,jpg,png}'
IMG_DEST = 'dist'

reportName = (name)->
	name + moment().format 'M-D-YY_hh:mm:ss'

indexImageSizes = (raw)->
	_(raw).chain()
		.countBy (img)-> "#{img.width} x #{img.height}"
		.reduce((memo, val, key)->
			memo.push({dimensions: key, count: val})
			memo
		, [])
		.sortBy((i)-> -1 * i.count)
		.value()

indexImageRatios = (raw)->
	_(raw).chain()
		.countBy 'ratio'
		.reduce((memo, val, key)->
			memo.push({ratio: key, count: val})
			memo
		, [])
		.sortBy((i)-> -1 * i.count)
		.value()

downloadImage = (uri, folder, callback) ->
	filename = Path.basename uri
	request.head(uri, (err, res, body) ->
		return callback 'failed' if err
		request(uri).pipe(fs.createWriteStream("#{folder}/#{filename}")).on('close', ()->
			callback null
		)
	)

# gm convert image.jpg -crop 1x1+0+0 test.txt
# gm convert image.jpg -fuzz 40% -trim -enhance -define jpeg:preserve-settings image-trimmed.jpg
gulp.task 'trim', ->
	gulp.src IMG_SRC
		.pipe gm (file)->
			file.define({ jpeg:'preserve-settings' })
				.fuzz('40%')
				.trim()
		.pipe gulp.dest IMG_DEST


gulp.task 'report', ->
	raw = []
	gulp.src IMG_SRC
		.pipe gm (file, done)->
			file.identify (err, ident)->
				console.log file if err
				return done err, file if err
				data = _.extend({}, ident)
				info = { width: data.size.width, height: data.size.height }
				ratio = info.width / info.height
				info.ratio = Number(ratio.toFixed(2))
				info.name = data.path.substr Path.resolve('src').length+1
				raw.push info
				done null, file
		.on 'error', ->
			console.log 'error', arguments[0]
			@emit 'end'
		.on 'end', ->
			report =
				sizes: indexImageSizes raw
				ratios: indexImageRatios raw
				raw: raw

			fs.writeFileSync(
				"reports/#{reportName('sizes-')}.json",
				JSON.stringify({ report: report }, null, 2)
			)


gulp.task 'download', (done)->
	brandList = (require './import/brands.json')

	brandList.forEach (bUri)->
		downloadImage bUri, 'src/brands', (err)->

