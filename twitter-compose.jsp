<%@ page language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.regex.*" %>
<%@ page import="java.sql.*" %>

<%
int uid = 1;
if(request.getMethod().equals("POST")) {
	//let's just pretend they're authorized
	String content = request.getParameter("content");
	uid = Integer.parseInt(request.getParameter("uid"));
	if(content != null) {
		Class.forName("com.mysql.jdbc.Driver").newInstance();
		Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/mbirnbaum", "mbirnbaum", "thisisapassword");
		con.setAutoCommit(false);

		PreparedStatement checkForHashtag = con.prepareStatement("SELECT id FROM hashtags WHERE content = ?");
		PreparedStatement insertHashTag = con.prepareStatement("INSERT INTO hashtags (content) VALUES (?)", Statement.RETURN_GENERATED_KEYS);
		PreparedStatement insertHashTweet = con.prepareStatement("INSERT INTO hash_tweets (tid, hash_id) VALUES (?, ?)");
		PreparedStatement checkUser = con.prepareStatement("SELECT uid FROM users WHERE username = ?");
		PreparedStatement insertMention = con.prepareStatement("INSERT INTO mentions (tid, tweeter, target) VALUES (?, ?, ?)");
		PreparedStatement insertTweet = con.prepareStatement("INSERT INTO tweets (uid, content) VALUES (?, ?)", Statement.RETURN_GENERATED_KEYS);
		insertTweet.setInt(1, uid);
		insertTweet.setString(2, content);
		insertTweet.executeUpdate();
		ResultSet genKeys = insertTweet.getGeneratedKeys();
		genKeys.next();
		int tweet_id = genKeys.getInt(1);

		Matcher m = Pattern.compile("(?<= #)[1-9a-zA-Z]+").matcher(content);
		while(m.find()) {
			String hash = m.group();
			checkForHashtag.setString(1, hash);
			int hash_id;
			ResultSet rs = checkForHashtag.executeQuery();
			if(rs.next()) hash_id = rs.getInt("id");
			else {
				insertHashTag.setString(1, hash);
				insertHashTag.executeUpdate();
				genKeys = insertHashTag.getGeneratedKeys();
				genKeys.next();
				hash_id = genKeys.getInt(1);
			}
			insertHashTweet.setInt(1, tweet_id);
			insertHashTweet.setInt(2, hash_id);
			insertHashTweet.executeUpdate();
		}

		m = Pattern.compile("(?<= @)[1-9a-zA-Z]+").matcher(content);
		while(m.find()) {
			String target = m.group();
			checkUser.setString(1, target);
			ResultSet rs = checkUser.executeQuery();
			if(rs.next()) {
				insertMention.setInt(1, tweet_id);
				insertMention.setInt(2, uid);
				insertMention.setInt(3, rs.getInt("uid"));
				insertMention.executeUpdate();
			}
		}
		
		con.commit();
	}
}
response.sendRedirect("twitter-home.jsp?id=" + uid);
%>
