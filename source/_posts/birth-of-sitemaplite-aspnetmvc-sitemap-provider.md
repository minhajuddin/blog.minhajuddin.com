title: The Birth of SiteMapLite (ASP.NET MVC Sitemap provider)
date: 2009-09-18
---

Alright, the last post about the json sitemap provider got some people interested in this utility. So, I thought of improving the code a bit more before actually coding up the 
Html helpers to render the navigation links. So, here we go. ( I named this utility <strong>SiteMapLite</strong> so that it's easy to reference it, 
If you've got a better name leave it in the comments ;) )  

When you think about a sitemap there are a few things which come to mind
 1. The Nodes: Sitemaps are all about nodes, where each node is a hyperlink pointing to a resource, In our code we have a class called the 
**SiteMapNode** which represents a single node in a SiteMap. 


~~~csharp

public class SiteMapNode {
public virtual int Id { get; set; }
        public virtual string Action { get; set; }
        public virtual string Controller { get; set; }
        public virtual string Title { get; set; }
        public virtual string Role { get; set; }
        public int ParentId { get; set; }
        public IEnumerable<SiteMapNode> Children;

        public virtual bool IsInRole(string role) {
            if (Role == null || Role.Trim().Length == 0) {
                return true;
            }
            int count = Role.Split(',').Count(x => x.Trim().Equals(role, StringComparison.OrdinalIgnoreCase));
            return count != 0;
        }
        public virtual bool IsRootNode {
            get { return ParentId == 0; }
        }
    }

~~~


 2. The Hierarchy: Once you have all the nodes you would want the SiteMap to be laid out in a hierarchical fashion, So you would have a root node(s) which would then have children nodes, and those children nodes might have their own children. In our project, this hierarchy is represented by a simple list of SiteMapNodes. This list would have just the root nodes. 

 3. You might be thinking how we can fashion the whole hierarchy by just using a simple list of root nodes, where do the children nodes go? The answer to that, is, every root node has a it's own list of children nodes, that is how we store the hierarchy in SiteMapLite. Now the HtmlHelper which is to be created just has to take the list of root nodes and render the main navigation bar. And then based on the current node, render it's second level navigation and so on. 

Now that we understand the basics of sitemaps, we can take a look at the architecture of our code. I have applied a few [SOLID][1] techniques to make the code more extensible. Take a look at the following class diagram to get a feel of the architecture.

<p>&#160;</p>

<p><img style="border-right-width: 0px; display: block; float: none; border-top-width: 0px; border-bottom-width: 0px; margin-left: auto; border-left-width: 0px; margin-right: auto"
title="SiteMapLite" border="0" alt="SiteMapLite" src="/images/SiteMapLite.png" width="501" height="404" /></p>

We have made the code more generic and flexible by moving the responsibility of reading the sitemap data to an interface called ISiteMapReader, 
Now, we can create any custom implementation of the ISiteMapReader which could read data from a json flat file or an XML file or a database or a webservice, 
and the code in the SiteMapService doesn't have to change even by a tiny bit to utilize these SiteMapReaders. Now the responsibility of the 
SiteMapReader is just to retrieve all the SiteMapNodes from the persistence medium and return them in their raw form (without any grouping). 
The job of Grouping the nodes into a set of root nodes and wiring up their child references is done by the ISiteMapService. The only method which the 
Html helper would use would be the <em>GetNodesForRole </em>method. This method would return a list of root nodes which are accessible to the input role. 
This gives us a solid foundation to create our HtmlHelpers and extend the code base as we like without changing existing code. 
I know I haven't explained the whole code, but by now you should have have a big picture of the whole project. 
To understand the code further, download the code from [http://github.com/minhajuddin/sitemaplite][2] . 
In a future blog post, I'll create a few HtmlHelpers to render a basic navigation dashboard.

Till next time

\[ [@minhajuddin][3] \]
  [1]: http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod
  [2]: http://github.com/minhajuddin/sitemaplite
  [3]: http://twitter.com/minhajuddin
