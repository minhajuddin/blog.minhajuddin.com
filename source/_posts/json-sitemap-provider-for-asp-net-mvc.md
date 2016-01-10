title: Enter the JSON SiteMap provider for ASP.NET MVC
date: 2009-09-08
---

The other day (a week ago) I was trying to get a nice menu show up in one of my ASP.NET MVC projects, I had seen [Maarten Balliauw][1]'s 
[ASP.NET MVC SiteMap provider][2] before. I thought I could just download the binaries, do some configuration and be done with it. 
But it turned out to be a lot more than that ;) . Well for starters, the asp.net mvc sitemap provider used the Authorize attribute to do the security trimming. 
Now in our application we used a different way to do authorization. In fact we had all the url's mapped to authorized roles using in database table. 
So, there was no easy way for me to get this working in our project (I guess today the mvc sitemap provider has a way to customize the way the role based trimming is done). 
That's when I thought I should come up with my own mvc sitemap, I said to myself "How hard can it really be?" :)  

To get an idea of what I was after, I downloaded the code of the [mvc sitemap provider from codeplex][3] and got coding on my new sitemap provider. 
I don't really like XML and all the gunk it comes with so I planned to use a different medium to store info about mvc sitemap nodes (.. part of the reason for not using XML 
is that I am not an expert at parsing XML ;) ). I really like JSON, so I decided to use a JSON file to store the info about the urls and their associated roles. 
I came up with a simple layout and saved the file as sitemap.json, the file initially looked like this: 


~~~js


[ {'Id':1,'Action':'Index','Controller':'Home','Title':'HOME','ParentId':0,'Role':'Anonymous,Administrator,Dashboard'}, 
{'Id':2,'Action':'About','Controller':'Home','Title':'About Us','ParentId':1,'Role':'Anonymous,Administrator,Dashboard'}, 
{'Id':3,'Action':'Faq','Controller':'Home','Title':'Faqs','ParentId':1,'Role':'Anonymous,Administrator,Dashboard'}, 
{'Id':4,'Action':'Contact','Controller':'Home','Title':'Contact Us','ParentId':1,'Role':'Anonymous,Administrator,Dashboard'}, 
{'Id':5,'Action':'Index','Controller':'Dashboard','Title':'Dashboard','ParentId':0,'Role':'Administrator'}, 
{'Id':6,'Action':'FunkyReport','Controller':'Dashboard','Title':'Funky Report','ParentId':5,'Role':'Administrator'}, 
{'Id':7,'Action':'Stats','Controller':'Dashboard','Title':'My Stats','ParentId':5,'Role':'Administrator'}, 
{'Id':8,'Action':'Stats','Controller':'Administrator','Title':'My Stats','ParentId':0,'Role':'Administrator'} ]


~~~


As you can see, each object in this array is a node. And each node has information about the 'Action', the 'Controller', the 'Title', a comma separated list of 'Roles', an 'Id' 
(to uniquely identify a node) and a 'ParentId' (to create a parent child relationship among the nodes. I know it doesn't look good but 
I've chosen this so that it's easy to parse stuff. I am using the [JSON.NET library][4] to do the JSON parsing, it's a very easy to use library to serialize or deserialize objects. With that aside, 
I created a couple of methods which would read the file and create a list of nodes and group them up. Take a look at them:


~~~csharp

    private void Init(string rawJsonData) { 
      JsonNodes = DeSerialize(rawJsonData); 
    } 
    protected virtual IList<JsonNode> DeSerialize(string rawJson) { 
      var nodes = JsonConvert.DeserializeObject<IList<JsonNode>>(rawJson); 
      return nodes; 
    }

    protected virtual IEnumerable<JsonNode> GroupNodes(IList<JsonNode> nodes) { 
      //get root nodes 
      var rootNodes = nodes.Where(x => x.ParentId == 0).ToList(); 
      //WL("Grouping {0} nodes in total and {1} root nodes", nodes.Count, rootNodes.Count()); 
      //populate child nodes for each root node 
      foreach (var node in rootNodes) { 
        var children = nodes.Where(x => x.ParentId == node.Id).ToList(); 
        //WL("Assigning {0} children to {1} node", children == null ? -1 : children.Count(), node.Title); 
        node.Children = children; 
      } 
      return rootNodes; 
    } 

~~~


The code is pretty self explanatory. All I am doing is getting a list of nodes, and then grouping them up. 
Once I group them it's just a matter of getting all the nodes, formatting them and printing it out to the screen, I'll post another blog entry about the menu rendering in a couple of days, 
[This is where you can grab the code for the JsonSiteMapProvider][5]

  [1]: http://blog.maartenballiauw.be
  [2]: http://mvcsitemap.codeplex.com/
  [3]: http://mvcsitemap.codeplex.com/
  [4]: http://www.codeplex.com/Json
  [5]: http://github.com/minhajuddin/sitemaplite/tree/master

