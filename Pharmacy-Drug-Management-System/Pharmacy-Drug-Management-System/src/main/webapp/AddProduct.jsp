<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/auth-seller.jspf" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<%
    String sid = (String) session.getAttribute("currentuser");

    String prname = request.getParameter("prname");
    String prid = request.getParameter("prid");
    String mfname = request.getParameter("mfname");
    String mdate = request.getParameter("mdate");
    String edate = request.getParameter("edate");

    String query1 = "SELECT pid FROM product WHERE pid=?";
    String query2 = "INSERT INTO product(pid,pname,manufacturer,mfg,exp,price) VALUES (?,?,?,?,?,?)";
    String query3 = "INSERT INTO inventory(pid,pname,sid,quantity) VALUES (?,?,?,?)";

    ResultSet rs = null;
    Connection conn = null;
    PreparedStatement ps1 = null;
    PreparedStatement ps2 = null;
    PreparedStatement ps3 = null;
    String target;

    try {
        int price = Integer.parseInt(request.getParameter("price"));
        int quantity = Integer.parseInt(request.getParameter("quantity"));

        conn = getConnection();
        ps1 = conn.prepareStatement(query1);
        ps1.setString(1, prid);
        rs = ps1.executeQuery();

        if (rs.next()) {
            target = "AddProductError.html";      // product id already exists
        } else {
            conn.setAutoCommit(false);            // both inserts succeed or neither does
            try {
                ps2 = conn.prepareStatement(query2);
                ps2.setString(1, prid);
                ps2.setString(2, prname);
                ps2.setString(3, mfname);
                ps2.setString(4, mdate);
                ps2.setString(5, edate);
                ps2.setInt(6, price);
                ps2.executeUpdate();

                ps3 = conn.prepareStatement(query3);
                ps3.setString(1, prid);
                ps3.setString(2, prname);
                ps3.setString(3, sid);
                ps3.setInt(4, quantity);
                ps3.executeUpdate();

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
            target = "AddInventory.jsp";
        }
    } catch (Exception e) {
        application.log("AddProduct failed", e);
        target = "AddProductError2.html";
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps1 != null) ps1.close(); } catch (Exception e) {}
        try { if (ps2 != null) ps2.close(); } catch (Exception e) {}
        try { if (ps3 != null) ps3.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
    response.sendRedirect(target);
%>
