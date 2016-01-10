title: backup mongodb databases to s3
date: 2011-08-02
---

Here are a bunch of scripts which can be used to backup your mongodb database files to S3.



~~~ruby

#mongodbbak
#!/usr/bin/env ruby
require 'rubygems'
require 'aws/s3'
require 'pony'

#run export
Dir.chdir("#{ENV['HOME']}/archives/mongodb/")
puts 'dumping..'
`mongodump`

#zip
puts 'compressing..'
hostname = `hostname`.chomp
file = "mongodb.#{hostname}.#{Time.now.strftime "%Y%m%d%H%M%S"}.tar.gz"
md5file = "#{file}.md5sum"
`tar cf - dump --remove-files| gzip > #{file}`
`md5sum #{file} > #{md5file}`

#copy
puts "copying to #{file} s3.."
AWS::S3::Base.establish_connection!(
    :access_key_id     => ENV['AMAZON_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
  )
AWS::S3::S3Object.store(file, open(file), 'cvbak')
puts "#{file} uploaded"
#create md5checksum
AWS::S3::S3Object.store(md5file, open(md5file), 'cvbak')
puts "#{md5file} uploaded"

#message
Pony.mail(:to => 'min@mailinator.com', :from => 'sysadmin@mailinator.com.com', :subject => "[sys] db on #{hostname} backed up to #{file}", :body => "mongodb database on #{hostname} has been successfully backed up to #{file}")
puts 'done'

~~~


~~~bash

#crontab -l 
@daily /bin/bash -i -l -c '/home/ubuntu/repos/server_config/scripts/mongodbbak' >> /tmp/mongobak.log 2>&1

~~~



~~~bash

#~/.bashrc
export AMAZON_ACCESS_KEY_ID='mykey'
export AMAZON_SECRET_ACCESS_KEY='mysecret'

~~~

