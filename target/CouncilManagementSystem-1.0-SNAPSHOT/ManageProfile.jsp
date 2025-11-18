<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, jakarta.servlet.http.*" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>
<%
  HttpSession s = request.getSession(false);
  if (s == null || s.getAttribute("userCategory") == null) {
    response.sendRedirect("index.jsp"); return;
  }
  String email = (String)s.getAttribute("userEmail");
  String userName = (String)s.getAttribute("userName");
  String category = (String)s.getAttribute("userCategory");
  String msg = request.getParameter("msg")!=null?request.getParameter("msg"):"";
  String errorMsg = request.getParameter("errorMsg")!=null?request.getParameter("errorMsg"):"";

  String first = "", last = "";
  try (Connection c = DBUtil.getConnection();
       PreparedStatement p = c.prepareStatement("SELECT firstname, lastname FROM login_table WHERE emailid=?")) {
    p.setString(1, email);
    try (ResultSet r = p.executeQuery()) { if (r.next()) { first=r.getString(1); last=r.getString(2); } }
  } catch (Exception ex) { msg = "Error: "+ex.getMessage(); }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Manage Profile</title>
  <link rel="stylesheet" href="assets/style.css">
  
</head>
<body>
<div class="dashboard-bg">
  <div class="overlay"></div>
  <div class="dashboard-container">
    <div class="dashboard-header">
      <h1>Manage Profile</h1>
      <p>Hello, <strong><%= userName %></strong> (<%= category %>)</p>
    </div>

    <% if (!msg.isEmpty()) { %>
      <p class="status-msg success"><%= msg %></p>
    <% } %>

    <form method="post" action="update_profile.jsp" class="application-form">
      <input type="hidden" name="emailid" value="<%= email %>">
      <div class="two-col">
        <div class="field">
          <label>First Name</label>
          <input class="input" name="firstname" value="<%= first %>">
        </div>
        <div class="field">
          <label>Last Name</label>
          <input class="input" name="lastname" value="<%= last %>">
        </div>
      </div>
      <button class="btn" type="submit">Save Changes</button>
    </form>

    <hr class="divider" style="margin:30px 0;border:1px solid rgba(255,255,255,0.08)">
    <h2 style="margin-bottom:10px;">Change Password</h2>

    <form method="post" action="ChangePasswordServlet" class="application-form" style="max-width:520px">
      <div class="field">
        <label>Current Password</label>
        <input class="input" type="password" name="currentPassword" required>
        <% if (!errorMsg.isEmpty()) { %>
          <p class="error-msg visible-msg"><%= errorMsg %></p>
        <% } %>
      </div>

      <div class="field">
        <label>New Password</label>
        <input class="input" type="password" name="newPassword" required>
      </div>

      <div class="field">
        <label>Confirm New Password</label>
        <input class="input" type="password" name="confirmPassword" required>
      </div>

      <p id="passwordError" class="error-msg"></p>
      <button class="btn" type="submit">Update Password</button>
    </form>

    <div class="back-btn-container">
      <a href="<%= "Admin".equalsIgnoreCase(category) ? "admin_dashboard.jsp" : "student_dashboard.jsp" %>" class="btn">Back to Dashboard</a>
    </div>
  </div>
</div>
</body>
</html>
