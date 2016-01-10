title: Get a Hello World ASP.NET MVC app up on Mono
date: 2009-12-12
---

<p>The other day I was trying to get started with Mono using ASP.NET MVC. 
  As usual I googled and found a useful post on it 
  <a title="http://beyondfocus.com/mono/asp-net-mvc-on-mono-two-options-for-the-ide-crowd/" href="http://beyondfocus.com/mono/asp-net-mvc-on-mono-two-options-for-the-ide-crowd/">
    http://beyondfocus.com/mono/asp-net-mvc-on-mono-two-options-for-the-ide-crowd/</a> .
  But, the post assumes you already know how to deploy an asp.net app on Mono. 
  Anyway here is my attempt to make it easier for folks to hop onto Mono.</p>  <p>&#160;</p>  
<p>Alright, so all I am trying to do here is get the ASP.NET MVC 1.0 default template up and running on Mono. 
  There are a few things you need, to get this working:</p>  <ol>   
  <li>You need to download a Virtual Machine image from <a title="http://www.go-mono.com/mono-downloads/download.html" 
      href="http://www.go-mono.com/mono-downloads/download.html">http://www.go-mono.com/mono-downloads/download.html</a> 
    OR install Mono 2.4, apache, mono_mod, and xsp if you already have a linux machine up and running.</li>    
  <li>Visual Studio with ASP.NET MVC 1.0 installed.</li> </ol>  <p>Now, once you have these pre-requisites, </p>  <ol>   
  <li>Fire up your vs and create a new ASP.NET MVC 1.0 project. 
    Change whatever text you want to in the template, Here is how mine looks on my machine:
    <a href="http://minhajuddin.com/wp-content/uploads/2009/12/image.png">
      <img style="border-bottom: 0px; border-left: 0px; display: block; float: none; margin-left: auto; border-top: 0px; margin-right: auto; border-right: 0px" 
      title="image" border="0" alt="image" src="https://substancehq.s3.amazonaws.com/static_asset/4f99dd0303b04d2e0300000f/image_thumb.png" width="571" height="230" />
    </a></li>    <li>Publish this application to a folder, say d:\binaries\mono_mvc. and then copy it to your Mono linux machine, copy it to the /srv/www/ folder.     
    <br />      <br /><a href="http://minhajuddin.com/wp-content/uploads/2009/12/image1.png">
      <img style="border-bottom: 0px; border-left: 0px; display: block; float: none; margin-left: auto; border-top: 0px; margin-right: auto; border-right: 0px"
      title="image" border="0" alt="image" src="https://substancehq.s3.amazonaws.com/static_asset/4f99dd0403b04d2e03000010/image_thumb1.png" width="271" height="132" /></a>      
    <br /></li>    <li>Once you've done that, head over to the <a title="http://go-mono.com/config-mod-mono/" href="http://go-mono.com/config-mod-mono/">
      http://go-mono.com/config-mod-mono/</a> to create your mod_mono configuration file. Fill out all the necessary details and click on the 
    Download button to download your newly configuration file.      
    <br /><a href="http://minhajuddin.com/wp-content/uploads/2009/12/image2.png">
      <img style="border-bottom: 0px; border-left: 0px; display: inline; border-top: 0px; border-right: 0px" 
      title="image" border="0" alt="image" src="https://substancehq.s3.amazonaws.com/static_asset/4f99dd0503b04d2e03000011/image_thumb2.png" width="581" height="700" /></a>
    <br /></li>    <li>Copy this new configuration file to the /etc/apache2/conf.d/ directory on your linux machine.     
    <br />      <br /><a href="http://minhajuddin.com/wp-content/uploads/2009/12/image3.png">
      <img style="border-bottom: 0px; border-left: 0px; display: inline; border-top: 0px; border-right: 0px" 
      title="image" border="0" alt="image" src="https://substancehq.s3.amazonaws.com/static_asset/4f99dd0703b04d2e03000012/image_thumb3.png" width="580" height="105" /></a>       
    <br /></li>    <li>The last thing you need to do is restart your apache server     <br />      
    <br /><a href="http://minhajuddin.com/wp-content/uploads/2009/12/image4.png">
      <img style="border-bottom: 0px; border-left: 0px; display: inline; border-top: 0px; border-right: 0px" 
      title="image" border="0" alt="image" src="https://substancehq.s3.amazonaws.com/static_asset/4f99dd0803b04d2e03000013/image_thumb4.png" width="587" height="74" />
    </a> </li>    <li>Now you can browse to http://localhost/&lt;your_application_name&gt; to see your asp.net mvc application in it's full glory :)     
    <br />      <br /><a href="http://minhajuddin.com/wp-content/uploads/2009/12/image5.png">
      <img style="border-bottom: 0px; border-left: 0px; display: inline; border-top: 0px; border-right: 0px" 
      title="image" border="0" alt="image" src="https://substancehq.s3.amazonaws.com/static_asset/4f99dd0903b04d2e03000014/image_thumb5.png" width="586" height="261" /></a>&#160; 
    <br /></li> </ol>  <p>This is obviously a contrived example, but you can see how easy it is to deploy an asp.net mvc application to a 
  linux box running apache and Mono. This is no more complicated than deploying a web app on a Windows box, and all props go to the 
  <a href="http://www.mono-project.com/Main_Page" target="_blank">Mono guys</a> for making Mono easier to use with every release. 
  I hope to dive in deeper into Mono real soon and I'll share my experiences with you guys.&#160;&#160; </p>
