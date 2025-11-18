<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.*, java.sql.*, com.mycompany.councilmanagementsystem.DBUtil" %>
<%
  HttpSession sess = request.getSession(false);
  if (sess == null || sess.getAttribute("userCategory") == null ||
      !"Admin".equalsIgnoreCase((String)sess.getAttribute("userCategory"))) {
    response.sendRedirect("index.jsp");
    return;
  }

  String msg = request.getParameter("msg") != null ? request.getParameter("msg") : "";
  String error = request.getParameter("error") != null ? request.getParameter("error") : "";
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>System Reset - Council Management</title>
  <link rel="stylesheet" href="assets/style.css">
  <style>
    .warning-box {
      background: rgba(255, 50, 50, 0.1);
      border: 1px solid rgba(255, 0, 0, 0.2);
      padding: 20px;
      border-radius: 10px;
      margin-bottom: 20px;
      color: #ff6b6b;
      font-weight: 600;
    }
  </style>
</head>
<body>
<div class="dashboard-bg">
  <div class="overlay"></div>
  <div class="dashboard-container">
    <div class="dashboard-header">
      <h1>System Reset</h1>
      <p>Use this feature to reset all council-related data for a new academic session.</p>
    </div>

    <% if (!msg.isEmpty()) { %>
      <p class="status-msg success"><%= msg %></p>
    <% } else if (!error.isEmpty()) { %>
      <p class="status-msg error"><%= error %></p>
    <% } %>

    <div class="warning-box">
      ⚠️ <strong>Warning:</strong> This will permanently delete all data from 
      <em>applications, interviews, council members, events, and notifications</em> tables. 
      Login data will remain safe.
    </div>

    <form method="post" action="ResetSystemServlet" class="application-form" onsubmit="return confirm('Are you sure you want to reset all council data for the new session? This cannot be undone.')">
      <button class="btn" type="submit">Reset Council Data</button>
    </form>

    <div class="back-btn-container">
      <a href="admin_dashboard.jsp" class="btn">Back to Dashboard</a>
    </div>
  </div>
</div>
</body>
</html>
