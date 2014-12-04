gulp = require 'gulp'
gm = require 'gulp-gm'
moment = require 'moment'
fs = require 'fs'
_ = require 'underscore'
Path = require 'path'

IMG_RATIO = 1.618

IMG_SRC = 'src/**/*.{gif,jpg,png}'
IMG_DEST = 'dist'

reportName = (name)->
	name + moment().format 'M-D-YY_hh:mm:ss'

indexImageSizes = (raw)->
	_(raw).countBy (img)-> "#{img.width} x #{img.height}"

indexImageRatios = (raw)->
	_(raw).countBy 'ratio'

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
				info = { width: ident.size.width, height: ident.size.height }
				ratio = info.width / info.height
				info.ratio = Number(ratio.toFixed(2))
				info.name = ident.path.substr Path.resolve('src').length+1
				raw.push info
				done null, file
		.on 'end', ->
			report =
				sizes: indexImageSizes raw
				ratios: indexImageRatios raw
				raw: raw

			fs.writeFileSync(
				"reports/#{reportName('sizes-')}.json",
				JSON.stringify({ report: report }, null, 2)
			)
