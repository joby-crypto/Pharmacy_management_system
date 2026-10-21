<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/auth-customer.jspf" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<%
    String pid = request.getParameter("pid");
    String uid = (String) session.getAttribute("currentuser");

    int qty;
    try {
        qty = Integer.parseInt(request.getParameter("orderquantity"));
    } catch (Exception e) {
        response.sendRedirect("Buy.jsp");
        return;
    }
    if (pid == null || qty <= 0) {
        response.sendRedirect("Buy.jsp");
        return;
    }

    Connection conn = null;
    ResultSet rs = null;
    PreparedStatement ps = null;
    PreparedStatement ps2 = null;
    String target = "Buy.jsp";

    String query1 = "SELECT p.pid, i.sid, p.price, i.quantity "
                  + "FROM inventory i JOIN product p ON p.pid = i.pid WHERE p.pid = ?";
    String query2 = "INSERT INTO orders(pid, sid, uid, quantity, price) VALUES (?,?,?,?,?)";

    try {
        conn = getConnection();
        ps = conn.prepareStatement(query1);
        ps.setString(1, pid);
        rs = ps.executeQuery();
        // Only place the order if the product exists and enough stock is left.
        // (A database trigger reduces the stock after the insert.)
        if (rs.next() && qty <= rs.getInt("quantity")) {
            ps2 = conn.prepareStatement(query2);
            ps2.setString(1, rs.getString("pid"));
            ps2.setString(2, rs.getString("sid"));
            ps2.setString(3, uid);
            ps2.setInt(4, qty);
            ps2.setInt(5, qty * rs.getInt("price"));
            ps2.executeUpdate();
            target = "Orders.jsp";
        }
    } catch (Exception e) {
        application.log("PlaceOrder failed", e);
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (ps2 != null) ps2.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
    response.sendRedirect(target);
%>
