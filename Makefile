.PHONY:clean
.PHONY:css
.PHONY:debug
.PHONY:minImg
.PHONY:concat

default:clean copy concat rename

debug:clean copy debugConcat

debugConcat:
	sh/concat.sh  make.conf debug

concat:
	sh/concat.sh  make.conf

rename:
	sh/rename.sh  make.conf

copy:
	mkdir -p dist/js
	cp src/jquery/* dist/js
	cp -r src/fonts   dist/
	cp -r src/data    dist/
	cp -r src/html/*  dist/
	cp -r src/root-source dist/

clean:
	rm -fr dist/fonts
	rm -fr dist/data

#用ImageMagick来压缩jpg格式图片，压缩率可以通过调整 sh 中的convert -quality 参数来修改。
convertImage:
	sh/convertjpg.sh "src/images"

#原来的压缩
minImg:
	rm -fr dist/images
	cp -r src/images  dist/
	node MinImage.js
