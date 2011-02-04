<%@ page import="java.io.*, java.text.*, java.net.*, java.util.*, org.hamamoto.ImageInfo" contentType="text/html; charset=UTF-8" %>
<%!
    private static final String version = "0.1.1";
    private static final int size = 160;
    private String user;
    private String dir;
    private String path;
    private int numOfImgs;
    private int numOfDirs;
    private List imgs;
    private String sort;

    private List getImages(File file) throws IOException {
        List imgs = new ArrayList();

        if (!file.exists()) {
            System.out.println(file.getCanonicalPath() + " not found.");
            return imgs;
        }

        File[] files = file.listFiles(
	   	        new FileFilter() {
    	            public boolean accept(File pathname) {
        	            return !pathname.isHidden() && pathname.canRead();
   	                }
                });

        for (int i = 0; i < files.length; i++) {
            if (files[i].isFile()) {
                if (files[i].getName().toLowerCase().endsWith("jpg") ||
                    files[i].getName().toLowerCase().endsWith("jpeg")) {
                    imgs.add(files[i]);
                    numOfImgs++;
                }
            } else if (files[i].isDirectory()) {
                imgs.add(files[i]);
                numOfDirs++;
            }
        }

        if ("name".equals(sort)) {
            Collections.sort(imgs,
     	            new Comparator() {
                        public int compare(Object o1, Object o2) {
                            return ((File)o1).getName()
                                .compareTo(((File)o2).getName());
                        }
                    });
        } else if ("date".equals(sort)) {
            Collections.sort(imgs,
     	            new Comparator() {
                        public int compare(Object o1, Object o2) {
                            return (int)(((File)o1).lastModified() - 
                                ((File)o2).lastModified());
                        }
                    });
        } else {
            Collections.sort(imgs);
        }

        return imgs;
    }

    private String encodeURL(String s, String enc)
            throws UnsupportedEncodingException {
        String[] str = s.split("/");
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < str.length; i++) {
            sb.append(URLEncoder.encode(str[i], enc));
            if (i < str.length - 1) sb.append("/");
        }
        return sb.toString();
    }
%>
<%
    // initialize member variables.
    user = request.getParameter("user");
    dir = request.getParameter("dir");
    if (dir == null) {
        dir = "";
    }
    path = new File("/home/" + user + "/public_html/img").getCanonicalPath()
            + "/";
    numOfImgs = 0;
    numOfDirs = 0;
    sort = request.getParameter("sort");
    imgs = getImages(new File(path + dir));
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Thumbnail Viewer</title>
<style>
<!--
body,td,div,.p,a{font-family:arial,sans-serif}
//-->
</style>
</head>
<body>

<table width="100%" border=0 cellpadding=0 cellspacing=0>
  <tr>
    <td bgcolor=#224499><img width=1 height=1 alt=""></td>
  </tr>
</table>

<table width="100%" border=0 cellpadding=0 cellspacing=0 bgcolor=#bbcced>
  <tr>
    <td bgcolor=#bbcced nowrap>
      <font size=+1>&nbsp;<b>Thumbnail Viewer</b></font> <font size=-1>version <%=version%></font>&nbsp;
    </td>
    <td	bgcolor=#bbcced align=right nowrap>
      <font size=-1>Images:&nbsp;<b><%=numOfImgs%></b>&nbsp;&nbsp;Directories:&nbsp;<b><%=numOfDirs%></b></font>&nbsp;
    </td>
  </tr>
</table>

<table width="100%" border=0 cellpadding=5 cellspacing=0>
  <tr>
    <td><font size=-1>
<%
    // display navigation links.
    if (dir.length() > 0) {
        out.print("<a href=\"/thumbview.jsp?user=" + user + "\">Top</a>");
        String[] dirs = dir.split("/");
        String curDir = "";
        for (int i = 0; i < dirs.length - 1; i++) {
            if (i == 0) {
                curDir += dirs[i];
            } else {
                curDir += "/" + dirs[i];
            }
            out.print("&nbsp;&gt;&nbsp;<a href=\"/thumbview.jsp?user="
                    + user + "&dir=" + curDir + "\">" + dirs[i]
                    + "</a>");
        }
        out.print("&nbsp;&gt;&nbsp;" + dirs[dirs.length - 1]);
    }

    out.println("</font></td>");

    // display sort buttons.
    out.print("<td align=right><font size=-1>" +
            "Sort by <a href=\"/thumbview.jsp?user="
            + user + "&dir=" + dir + "&sort=name\">Name</a>"
            + " | <a href=\"/thumbview.jsp?user="
            + user + "&dir=" + dir + "&sort=date\">Date</a>");
%>
    </font></td>
  </tr>
</table>

<table align=center border=0 cellpadding=5 cellspacing=0 width="100%">
<%
    // display images and directories.
    List imgs = getImages(new File(path + dir));
    int i = 0;
    for (Iterator it = imgs.iterator(); it.hasNext(); i++) {
        if (i % 4 == 0) {
            if (i / 4 % 2 == 0) {
                out.println("<tr bgcolor=#e7eefc>");
            } else {
                out.println("<tr>");
            }
        }
        out.println("<td align=center valign=middle width=\"23%\"><br>");
        File img = (File)it.next();
        String relativePath = img.getCanonicalPath().replaceAll(path, "");
        if (img.isFile()) {
            // use ImageInfo utility class.
            ImageInfo ii = new ImageInfo();
            FileInputStream fis = new FileInputStream(img);
            BufferedInputStream bis = new BufferedInputStream(fis);
            ii.setInput(bis);
            ii.check();
            bis.close();
            double ratio = Math.min((double)size / ii.getWidth(),
                    (double)size / ii.getHeight());
            // Japanese file & directory names must be encoded in
            // UTF-8 for Apache to understand.
            String src = "/~" + user + "/img/" +
//            		encodeURL(relativePath, "UTF-8");
                        relativePath;
            out.print("<a href=\"" + src + "\">");
            out.print("<img src=\"/thumbnail?user=" + user
                    + "&img=" + relativePath + "&size=" + size
                    + "\" width=\"" + (int)(ii.getWidth() * ratio)
                    + "\" height=\"" + (int)(ii.getHeight() * ratio)
                    + "\" />");
            /*
            out.print("<img src=\"" + src
                    + "\" width=\"" + (int)(ii.getWidth() * ratio)
                    + "\" height=\"" + (int)(ii.getHeight() * ratio) + "\" />");
            */
            out.println("</a>&nbsp;<br>");
            out.println("<b>" + img.getName() + "</b><br>");
            out.println("<font size=-1>" + ii.getWidth() + " x "
                    + ii.getHeight() + " pixels - "
                    + Math.round(img.length() / 1024) + "k<br>");
            Date date = new Date(img.lastModified());
            DateFormat df = DateFormat.getDateTimeInstance(
                    DateFormat.MEDIUM, DateFormat.MEDIUM, Locale.JAPAN);
            out.println("<font color=#008000>" + df.format(date));
            out.println("</font></font><br><br>");
        } else if (img.isDirectory()) {
            out.print("<a href=\"/thumbview.jsp?user=" + user
                    + "&dir=" + relativePath + "\">");
            out.print("<img src=\"/dir.png\" border=\"0\">");
            out.println("</a>&nbsp;<br>");
            out.println("<b>" + img.getName() + "</b></font><br><br>");
        }
        out.println("</td>");
        if (i % 4 == 3 || !it.hasNext()) {
            out.println("</tr>");
        }
    }
%>
</table>
<br>

<hr noshade size="1">

<a href="http://www.debian.org/"><img src="debian.jpg"
width="90" height="30" border="0" align="right" alt="Powered by Debian"></a>
<font size=-1>Copyright &copy; 2001-2005 hamamoto.org<br>
Contact <a href="mailto:gyo@hamamoto.org">Gyo Hamamoto</a> with any
queries. 2005-07-13.</font>

</body>
</html>
