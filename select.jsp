<%@ page language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mysql.jdbc.*" %>

<HTML>
<HEAD>
<TITLE>Select Student</TITLE>
</HEAD>
<BODY BGCOLOR="white">
<img src = "dalton.jpg">
<H3> OPTIONS MENU </H3>
<%
	int count = 0;     


		

	String data = request.getParameter("key"); 	
	out.println(data);
/*
      try {



	out.println("the key is: " + data);

         String url = "";

         //sql query:
	 String query = "select stuff from table where key=" + data; //get all rows int he student database

	 //open sql:
         Class.forName("com.mysql.jdbc.Driver").newInstance();
         url = "jdbc:mysql://localhost:3306/gordie";   //your db ex) ljadow
         con = DriverManager.getConnection(url, "gordie", "happy95"); //mysql id &  pwd
         java.sql.Statement stmt = con.createStatement();
         
	 //executes the query:
	 java.sql.ResultSet rs = stmt.executeQuery(query);


	//loop through result set until there is not a next:
         while(rs.next())
	 {
		tweet_count = rs.getString("tweet_count");
	 	count = count +1;

	 } //end while

      } catch (Exception e) {
         out.println(e);
      }

*/
%>

	<h1> count is: <%=count%>

</BODY>
</HTML>


