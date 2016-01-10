title: SiteMapLite, Adding Html helpers
date: 2009-09-20
---

This might actually be my first open source project coming to fruition. I have created a lot of special Abandon-ware (Special in that they were abandoned before completion).   

Anyway, things are looking good with SiteMapLite. In today's iteration I have added a nice MenuHelper to help us render the main navigation bar. 
It also has a nice Cached SiteMap service which wraps around the actual SiteMap service and caches it nicely, so that the text files are not read and parsed for each request.   

~~~csharp

    public static class MenuHelper {


        public static string RenderMainNav(this HtmlHelper helper) {
            return RenderMainNav(helper, null);
        }

        public static string RenderMainNav(this HtmlHelper helper, object htmlAttributes) {

            var nodes = CachedSiteMapService.Service.GetNodesForRole("Administrator");
            StringBuilder sb = new StringBuilder();

            sb.Append("<ul ");

            AppendHtmlAttributes(sb, htmlAttributes);

            sb.Append(">");

            foreach (var node in nodes) {
                sb.AppendFormat("<li><a href='/{0}/{1}' title={2}>{2}</a></li>\r\n", node.Controller, node.Action, node.Title);
            }
            sb.Append("</ul>");
            return sb.ToString();
        }

        private static void AppendHtmlAttributes(StringBuilder sb, object htmlAttributes) {
            PropertyDescriptorCollection properties = TypeDescriptor.GetProperties(htmlAttributes);
            foreach (PropertyDescriptor property in properties) {
                sb.AppendFormat(" {0}='{1}' ", property.Name.Trim('@')/* Remove the @ if the attribute is @class */, property.GetValue(htmlAttributes));
            }
        }
    }

~~~


If you see, this MenuHelper just uses the CachedSiteMapService.Service instance to get the nodes for the role 
Administrator. As of now, we have hard coded the role to Administrator. In a future iteration, We'll write code so that it uses the role of current session. 
This code creates a simple list of urls and it appends any html attributes passed in input parameter to the ul html attribute. 
[Checkout the updated SiteMapLite code at GitHub][1].

Till next time

\[ [@minhajuddin][2] \]
  [1]: http://github.com/minhajuddin/sitemaplite
  [2]: http://twitter.com/minhajuddin
