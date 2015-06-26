<%@ page language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.regex.*" %>

<%
String hashName = null;
int count = -1;
ResultSet rs = null;

java.util.Date now = new java.util.Date();

Class.forName("com.mysql.jdbc.Driver").newInstance();
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/mbirnbaum", "mbirnbaum", "thisisapassword");
PreparedStatement stmt = null;
try {
	int hashId = Integer.parseInt(request.getParameter("id"));
	stmt = con.prepareStatement("SELECT (SELECT COUNT(*) FROM hash_tweets WHERE hash_id = ?) AS count, "
						+ "(SELECT content FROM hashtags WHERE id = ?) AS hashtag");
	stmt.setInt(1, hashId);
	stmt.setInt(2, hashId);

	rs = stmt.executeQuery();
	if(rs.next()) {
		count = rs.getInt("count");
		hashName = rs.getString("hashtag");

		stmt = con.prepareStatement("SELECT tweets.tid, tweets.uid, tweets.content, tweets.created, users.username, users.displayname FROM tweets "
					+ "JOIN users ON users.uid = tweets.uid JOIN hash_tweets ON hash_tweets.tid = tweets.tid "
					+ "WHERE hash_tweets.hash_id = ? ORDER BY created DESC");
		stmt.setInt(1, hashId);
		rs = stmt.executeQuery();
	}
} catch (NumberFormatException nfe) { }

String loginName = null;
try {
	stmt = con.prepareStatement("SELECT displayname FROM users WHERE uid = ?");
	stmt.setInt(1, (Integer) session.getAttribute("user_id"));
	ResultSet tmp = stmt.executeQuery();
	if(tmp.next()) loginName = tmp.getString("displayname");
} catch (NullPointerException npe) { }
%>
<%!
public String timeAgo(java.util.Date ts, java.util.Date now) {
	Calendar tsc = Calendar.getInstance();
	Calendar nowc = Calendar.getInstance();
	tsc.setTime(ts);
	nowc.setTime(now);
	if(tsc.get(Calendar.YEAR) != nowc.get(Calendar.YEAR)) {
		DateFormat df = new SimpleDateFormat("d MMM, yyyy");
		return df.format(tsc.getTime());
	}
	else if(tsc.get(Calendar.DAY_OF_YEAR) != nowc.get(Calendar.DAY_OF_YEAR)) {
		DateFormat df = new SimpleDateFormat("MMM d");
		return df.format(tsc.getTime());
	} else {
		if(tsc.get(Calendar.HOUR_OF_DAY) != nowc.get(Calendar.HOUR_OF_DAY)) return (nowc.get(Calendar.HOUR_OF_DAY) - tsc.get(Calendar.HOUR_OF_DAY)) + "h";
		else if(tsc.get(Calendar.MINUTE) != nowc.get(Calendar.MINUTE)) return (nowc.get(Calendar.MINUTE) - tsc.get(Calendar.MINUTE)) + "m";
		else return (nowc.get(Calendar.SECOND) - tsc.get(Calendar.SECOND)) + "s";
	}
}
%>
<%!
public String parseContent(String content, Connection con) {
	final String FORMAT = "<a href='%1$s' class='twitter-timeline-link' title='%2$s' dir='ltr'><span class='js-display-url'>%2$s</span></a>"; //(url, content)
	try {
		PreparedStatement findHashtag = con.prepareStatement("SELECT id FROM hashtags WHERE content = ?");
		PreparedStatement findUser = con.prepareStatement("SELECT uid FROM users WHERE username = ?");
		Matcher m = Pattern.compile("(?<=#)[1-9a-zA-Z]+").matcher(content);
		while(m.find()) {
			String hashtag = m.group();
			findHashtag.setString(1, hashtag);
			ResultSet rs = findHashtag.executeQuery();
			if(rs.next()) {
				content = content.replace("#" + hashtag, String.format(FORMAT, "twitter-hashtag.jsp?id=" + rs.getInt("id"), "#" + hashtag));
			}
		}
		m = Pattern.compile("(?<=@)[1-9a-zA-Z]+").matcher(content);
		while(m.find()) {
			String user = m.group();
			findUser.setString(1, user);
			ResultSet rs = findUser.executeQuery();
			if(rs.next()) {
				content = content.replace("@" + user, String.format(FORMAT, "twitter-home.jsp?id=" + rs.getInt("uid"), "@" + user));
			}
		}
		return content;
	} catch(SQLException sqle) { return sqle.getMessage(); }
}
%>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title></title>
    <meta name="description" content="">
    <meta name="author" content="">
    <style type="text/css">
    	body {
    		padding-top: 60px;
    		padding-bottom: 40px;
    	}
    	.sidebar-nav {
    		padding: 9px 0;
    	}
    </style>    
    <link rel="stylesheet" href="css/gordy_bootstrap.min.css">
</head>
<body class="user-style-theme1">
	<div class="navbar navbar-inverse navbar-fixed-top">
		<div class="navbar-inner">
			<div class="container">
                <i class="nav-home"></i> <a href="twitter-signin.jsp" class="brand">!Twitter</a>
				<div class="nav-collapse collapse">
					<p class="navbar-text pull-right"><% if(loginName != null ) { %>Logged in as <%= loginName %> <a href="twitter-signout.jsp">Sign out</a><% } else { %><a href="twitter-signin.jsp" class="navbar-link">Sign in</a><% } %>
					</p>
					<ul class="nav">
						<li class="active"><a href="twitter-home.jsp">Home</a></li>
						<li><a href="queries.html">Test Queries</a></li>
						<li><a href="twitter-signin.html">Main sign-in</a></li>
					</ul>
				</div><!--/ .nav-collapse -->
			</div>
		</div>
	</div>

    <div class="container wrap">
        <div class="row">

            <!-- left column -->
            <div class="span4" id="secondary">
                <div class="module mini-profile">
                    <div class="content">
                        <div class="account-group">
                            <a href="#">
                                <img class="avatar size32" src="images/pirate_normal.jpg" alt="Gordy">
                                <b class="fullname">Results for #<%= hashName %></b>
                                <small class="metadata">Results: <%= count %></small>
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- right column -->
            <div class="span8 content-main">
                <div class="module">
                    <div class="content-header">
                        <div class="header-inner">
                            <h2 class="js-timeline-title">Tweets</h2>
                        </div>
                    </div>

                    <!-- new tweets alert -->
                    <div class="stream-item hidden">
                        <div class="new-tweets-bar js-new-tweets-bar well">
                            2 new Tweets
                        </div>
                    </div>

                    <!-- all tweets -->
		    <div class="stream home-stream">

			<%
			if(rs != null && rs.next()) {
				do {
					int tid = rs.getInt("tid");
					int uid = rs.getInt("uid");
					String content = rs.getString("content");
					String tweetUsername = rs.getString("username");
					String tweetDisplayName = rs.getString("displayname");
					Timestamp timestamp = rs.getTimestamp("created");
			%>	
			<div class="js-stream-item stream-item expanding-string-item">
			    <div class="tweet original-tweet">
				<div class="content">
				    <div class="stream-item-header">
					<small class="time">
					    <a href="#" class="tweet-timestamp" title="10:15am - 16 Nov 12">
						<span class="_timestamp"><%= timeAgo(timestamp, now) %></span>
					    </a>
					</small>
					<a class="account-group" href="twitter-home.jsp?id=<%= uid %>">
					    <img class="avatar" src="images/obama.png" alt="Barak Obama">
					    <strong class="fullname"><%= tweetDisplayName %></strong>
					    <span>&rlm;</span>
					    <span class="username">
						<s>@</s>
						<b><%= tweetUsername %></b>
					    </span>
					</a>
				    </div>
				    <p class="js-tweet-text">
					<%= parseContent(content, con) %>
				    </p>
				</div>
			    </a>
				<div class="expanded-content js-tweet-details-dropdown"></div>
			    </div>
			</div><!-- end tweet -->
			<%
				} while(rs.next());
			} else if(count == 0) {
			%>
				<div class="stream-item">
				    <div class="tweet">
					<div class="content">
						<p>There doesn't seem to be anything here...</p>
					</div>
				    </div>
				</div>
			<%
			} else {
			%>
				<div class="stream-item">
				    <div class="tweet">
					<div class="content">
						<p>An error occurred, please try again later</p>
					</div>
				    </div>
				</div>
			<%
			}
			%>
                    </div>
                    <div class="stream-footer"></div>
                    <div class="hidden-replies-container"></div>
                    <div class="stream-autoplay-marker"></div>
                </div>
                </div>
               
            </div>
        </div>
    </div>
     <!-- Le javascript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
     <script type="text/javascript" src="js/main-ck.js"></script>
  </body>
</html>
