<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<%
    String uid = request.getParameter("userid");
    String pass = request.getParameter("password");
    String type = request.getParameter("utype");

    if (uid == null || pass == null || !("1".equals(type) || "2".equals(type))) {
        response.sendRedirect("Login.html");
        return;
    }

    boolean isCustomer = "1".equals(type);
    String query = isCustomer
            ? "SELECT pass FROM customer WHERE uid=?"
            : "SELECT pass FROM seller WHERE sid=?";

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String target = null;

    try {
        conn = getConnection();
        ps = conn.prepareStatement(query);
        ps.setString(1, uid);
        rs = ps.executeQuery();

        if (!rs.next()) {
            target = "LoginError2.html";          // unknown user id
        } else if (!pass.equals(rs.getString(1))) {
            target = "LoginError1.html";          // wrong password
        } else {
            // Success: start a fresh session (avoids session fixation)
            HttpSession old = request.getSession(false);
            if (old != null) old.invalidate();
            HttpSession httpSession = request.getSession(true);
            httpSession.setAttribute("currentuser", uid);
            httpSession.setAttribute("usertype", isCustomer ? "customer" : "seller");
            target = isCustomer ? "Homepage.jsp" : "SellerHomepage.jsp";
        }
    } catch (Exception e) {
        application.log("Login failed", e);
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }

    if (target != null) {
        response.sendRedirect(target);
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Login</title>
</head>
<body>
    <p>Could not connect to the database. Please check the connection settings and try again.</p>
    <p><a href="Login.html">Back to login</a></p>
</body>
</html>
