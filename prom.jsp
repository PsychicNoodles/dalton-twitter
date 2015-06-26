<%@ page language="java" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Prom?</title>
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">

  <!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
  <!--[if lt IE 9]>
    <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
  <![endif]-->

  <!-- Fav and touch icons -->
  <link rel="shortcut icon" href="../assets/ico/favicon.ico">
  <link rel="apple-touch-icon-precomposed" sizes="144x144" href="../assets/ico/apple-touch-icon-144-precomposed.png">
  <link rel="apple-touch-icon-precomposed" sizes="114x114" href="../assets/ico/apple-touch-icon-114-precomposed.png">
  <link rel="apple-touch-icon-precomposed" sizes="72x72" href="../assets/ico/apple-touch-icon-72-precomposed.png">
  <link rel="apple-touch-icon-precomposed" href="../assets/ico/apple-touch-icon-57-precomposed.png">
</head>

<body>
	<div class="jumbotron">
		<div class="container text-center">
<%
if(request.getMethod().equals("GET")) {
%>
			<h1>Sito&euml;</h1>
			<h2>will you go to <b>prom</b> with me?</h2>
			<div class="row">
				<form method="post">
					<div class="col-md-3 col-md-offset-3"><input type="submit" class="btn btn-primary btn-lg" value="Yes"></div>
					<div class="col-md-3"><input type="submit" class="btn btn-lg" value="No" disabled></div>
			</div>
<%
} else {
%>
			<h2>Your decision has been recorded!</h2>
			<h3>(though I'd appreciate it if you would text me your response too)</h3>
<%
	Class.forName("com.mysql.jdbc.Driver").newInstance();
	Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/mbirnbaum", "mbirnbaum", "thisisapassword");
	Statement stmt = con.createStatement();
	stmt.executeUpdate("INSERT INTO secret (response) VALUES (true)");
}
%>
		</div>
	</div>
</body>
</html>
