title: How to extract images from a pdf and reduce their size
date: 2016-02-16 13:14:05
tags:
- PDF
---

 1. Extract the images into a temporary folder. Twiddle with the quality value to reduce the size.
  ~~~
  convert \
  -verbose \
  -density 150 \
  -trim \
  source-pdf-file.pdf
  -quality 50 \
  -sharpen 0x1.0 \
  image-prefix.jpg
  ~~~

 2. Create the pdf back from all the images.
  ~~~
  convert *.jpg output-file.pdf
  ~~~
