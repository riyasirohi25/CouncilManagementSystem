<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, jakarta.servlet.http.*" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>
<%
  request.setCharacterEncoding("UTF-8");
  HttpSession s = request.getSession(false);
  if (s == null || s.getAttribute("userEmail") == null) { response.sendRedirect("index.jsp"); return; }

  String email = request.getParameter("emailid");
  String firstname = request.getParameter("firstname");
  String lastname = request.getParameter("lastname");

  String go = "ManageProfile.jsp?msg=Profile%20updated";
  try (Connection c = DBUtil.getConnection();
       PreparedStatement p = c.prepareStatement("UPDATE login_table SET firstname=?, lastname=? WHERE emailid=?")) {
      p.setString(1, firstname);
      p.setString(2, lastname);
      p.setString(3, email);
      p.executeUpdate();
      s.setAttribute("userName", firstname+" "+lastname);
  } catch (Exception ex) {
      go = "ManageProfile.jsp?msg="+java.net.URLEncoder.encode("Error: "+ex.getMessage(),"UTF-8");
  }
  response.sendRedirect(go);
%>
