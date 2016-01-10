title: how to setup solr and sunspot on a rails production server
date: 2011-11-10
---

Solr is an awesome app built on top of Lucene for fulltext search. However, setting
it up can be a pain if you don't find the right guide, or if you miss some small
detail. So, here is my attempt to document the process of setting up solr in
development and production using a rails app as an example.

Solr and Lucene are java apps, so you need java to get this stuff working,
I installed sun-jdk just to play it safe, as far as I know it works well
even with openjdk.

Steps to setup solr on production

  1.  Install Sun JDK:

~~~sh

#install and setup sun jdk
echo "deb http://archive.canonical.com/ $(lsb_release -cs) partner"| sudo tee -a /etc/apt/sources.list > /dev/null
sudo apt-get update
sudo apt-get install sun-java6-jre sun-java6-bin sun-java6-jdk -y
sudo update-alternatives --config java
echo 'export JAVA_HOME=/usr/lib/jvm/java-6-sun/' >> ~/.bashrc

~~~


  2. Download and setup tomcat: you'll need to setup tomcat version 6.0 for your production server. Download the latest V6 tomcat files from [http://tomcat.apache.org/download-60.cgi](http://tomcat.apache.org/download-60.cgi). Now, extract them into `~/apps`.

  3. Download or build the solr war files and copy them to `/apps/solr`. You can find the links at: [http://lucene.apache.org/solr/](http://lucene.apache.org/solr/) or [http://www.apache.org/dyn/closer.cgi/lucene/solr/](http://www.apache.org/dyn/closer.cgi/lucene/solr/). The war file is usually in a folder called `dist` and has a filename like `apache-solr-3.4.0.war`

  4. Create a file  ~/apps/tomcat/conf/Catalina/localhost/solr-appname.xml
     with the following content


~~~xml


<?xml version="1.0" encoding="utf-8"?>
<!-- I usually create this file in the rails app config/ directory and symlink
it to the ~/tomcat/conf/Catalina/localhost/ directory-->
<!-- the docBase path should point to your solr.war file -->
<Context docBase="/home/minhajuddin/apps/solr/solr.war" debug="0" crossContext="true">
  <!-- the value string should point to your apps solr directory -->
  <Environment name="solr/home" type="java.lang.String" value="/home/minhajuddin/spikes/solr-blog/solr" override="true"/>
  <!-- value= app-name/solr -->
</Context>


~~~


*Steps till this point are the same for any kind of solr installation, be it for a rails or any other app.*

  5. I use the sunspot\_rails gem in my rails application, when using this, you can run `rails g sunspot_rails:install` to create a `config/sunspot.yml` file. Once you have the config file, change the production config values to point to the right port and path, e.g:

~~~yaml

..
production:
  solr:
    hostname: localhost
    port: 8080
    path: '/solr-odir/'

~~~


  6. Run the `bundle exec rake sunspot:solr:start` command once, on the development machine, to generate the solr configuration files. And push this code to the production server.

That's all. Setting solr is not very straightforward, but once you have it set
up, it's very easy to setup additional apps with the same solr server.

On a development machine, all you need to get solr working is: install java (check step 1) and setup sunspot (check step 5), and start the solr server with `bundle exec rake sunspot:solr:start`


###Resources###

 - [https://help.ubuntu.com/community/Java](https://help.ubuntu.com/community/Java)
 - [http://wiki.apache.org/solr/SolrInstall](http://wiki.apache.org/solr/SolrInstall)
 - [http://www.tc.umn.edu/~brams006/solr_ubuntu.html](http://www.tc.umn.edu/~brams006/solr_ubuntu.html)
 - [http://railscasts.com/episodes/278-search-with-sunspot](http://railscasts.com/episodes/278-search-with-sunspot)
 - [https://github.com/outoftime/sunspot](https://github.com/outoftime/sunspot)
 - [https://github.com/sunspot/sunspot/wiki](https://github.com/sunspot/sunspot/wiki)
