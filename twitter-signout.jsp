<%@ page language="java" %>
<%
session.removeAttribute("user_id");
response.sendRedirect("twitter-signin.jsp");
%>
