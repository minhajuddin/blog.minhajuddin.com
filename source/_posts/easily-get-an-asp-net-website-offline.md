title: Quick and Dirty way to get an ASP.NET website offline
date: 2009-09-01
---

I never thought that I was gonna write code for an ASP.NET Webforms project again. I've been creating all my projects in ASP.NET MVC since it hit beta.
But, I guess Webforms is really good at some stuff, Coming up with quick and dirty web apps :)

Alright, So, I've got a web application which was created in ASP.NET MVC. The administrators of this web app want to control when the site is up. 
It's basically a webapp for processing some stuff which happens only at day time. 
So, they don't want the users (their agents) to go around and mess with the site during the night time or as soon as they get out of the office. 
We already had a nice web app with an administrator console through which the admins can do a lot of stuff like adding/de-activating users etc,. 
The administrators wanted a feature through which they could bring the site down or up using their admin page. A simple search showed up a lot of interesting articles, 
[This one by Rick Strahl][1] documents how you can take down an app, and bring it up without 
using "app_offline.htm" files. I didn't want to take that route, because I think
the app_offline way is the best, because it shuts down the application and
unloads the application domain, You can find some more interesting info about it
in [this post by Scott Gu][2].
Now, the downside of using this kind of approach is that, once the application is down, there is no way to bring it up using the same site.

Now, let's see how we can use this nifty little feature which is available for asp.net 2.0+ apps to come up with an admin page through which we can take the site down or bring it back up.

1) The first thing you need to do is create a basic Webforms website or Web application from Visual Studio. 
On the default page you would want a few textboxes, radio buttons and a submit button, which looks like

<img class="aligncenter size-full wp-image-25" title="site_admin_blog_post1" src="/images/site_admin_blog_post1.PNG" alt="site_admin_blog_post1" width="316" height="175" />


~~~html

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" 
Inherits="Cosmicvent.SiteAdmin._Default" %>
  Site Admin
<form id="form1">
<div>

      <label for="UserName">
        UserName:</label>

      <label for="Password">
        Password:</label></div>
</form>

~~~


2) This is the fragment of code which creates this GUI, Nothing too fancy.

3) Once we have that, it's basically an exercise in creating some code which does the user/password matching and creates an app_offline.htm file in the right location.

~~~csharp

using System;
using System.IO;
using System.Web.Security;

namespace Cosmicvent.SiteAdmin {
    public partial class _Default : System.Web.UI.Page {
        private const string VALID_USERNAME = "administrator";
        private const string VALID_HASHED_PASSWORD = "8D31D551A44B2DE3DFFA85842ABF38A8ACF14775";
        private const string APP_OFFLINE_PATH = @"C:\";
        private const string APP_OFFLINE_BACKUP_NAME = "app_offline.htm.bak";
        private const string APP_OFFLINE_FILE_NAME = "app_offline.htm";
        private const string APP_OFFLINE_CONTENT = @"
            The site has been taken offline for Maintenance
<h2>The site has been taken offline for maintenance</h2>
We are sorry for the incovenience. Please check back again some time later

                <!--
                      Here is some junk data for you IE !!!
Go to http://minhajuddin.com
Go to http://minhajuddin.com
Go to http://minhajuddin.com
Go to http://minhajuddin.com
Go to http://minhajuddin.com
Go to http://minhajuddin.com
Go to http://minhajuddin.com
Go to http://minhajuddin.com
Go to http://minhajuddin.com
Go to http://minhajuddin.com
Go to http://minhajuddin.com
Go to http://minhajuddin.com
Go to http://minhajuddin.com
Go to http://minhajuddin.com
Go to http://minhajuddin.com
Go to http://minhajuddin.com
                 -->
            ";

        protected void Page_Load(object sender, EventArgs e) {
        }

        protected void SubmitButton_Click(object sender, EventArgs e) {
            if (UserIsValid()) {
                string backupFilePath = Path.Combine(APP_OFFLINE_PATH, APP_OFFLINE_BACKUP_NAME);
                string appOfflineFilePath = Path.Combine(APP_OFFLINE_PATH, APP_OFFLINE_FILE_NAME);
                if (TakeOfflineRadioButton.Checked) {
                    //create or rename the backup file
                    if (File.Exists(backupFilePath) && !File.Exists(appOfflineFilePath)) {
                        //rename
                        RenameFile(backupFilePath, appOfflineFilePath);
                    } else if (!File.Exists(appOfflineFilePath)) {
                        //create
                        CreateAppOffline(appOfflineFilePath);
                    }
                    output.InnerText = &amp;quot;Site taken down successfully&amp;quot;;
                } else if (BringUpOnlineRadioButton.Checked) {
                    //rename the app_ofline file
                    if (File.Exists(appOfflineFilePath)) {
                        //rename
                        RenameFile(appOfflineFilePath, backupFilePath);
                    }
                    output.InnerText = "Site brought up successfully";
                }
            } else {
                output.InnerText = "Invalid username or password";
            }
        }

        private void CreateAppOffline(string appOfflineFilePath) {
            using (StreamWriter streamWriter = File.CreateText(appOfflineFilePath)) {
                streamWriter.Write(APP_OFFLINE_CONTENT);
            }
        }

        private void RenameFile(string backupFilePath, string appOfflineFilePath) {
            File.Move(backupFilePath, appOfflineFilePath);
        }

        private bool UserIsValid() {
            return VALID_USERNAME.Equals(UserName.Text, StringComparison.OrdinalIgnoreCase) &&
                   VALID_HASHED_PASSWORD.Equals(Hash(Password.Text), StringComparison.OrdinalIgnoreCase);
        }

        private string Hash(string text) {
            return FormsAuthentication.HashPasswordForStoringInConfigFile(text, "SHA1");
        }
    }
}

~~~

The code is pretty much self explanatory, Hope it helps someone.
You just have to be careful about a couple of things:

 1. You still have to run this on a different website
 2. You need to give the right privileges on the directory APP_OFFLINE_PATH to the user which runs the IIS worker process. For IIS7 this is the NETWORK SERVICE user by default.
 
And before I forget, You can get the source code for this project from my git repository hosted on [github][3] at [http://github.com/minhajuddin/blog_demos/tree/master][4]

  [1]: http://www.west-wind.com/WebLog/posts/6397.aspx
  [2]: http://weblogs.asp.net/scottgu/archive/2005/10/06/426755.aspx
  [3]: http://github.com
  [4]: http://github.com/minhajuddin/blog_demos/tree/master
