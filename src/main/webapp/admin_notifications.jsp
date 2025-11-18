<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*, jakarta.servlet.http.*" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>

<%
    HttpSession usersession = request.getSession(false);
    if (session == null || session.getAttribute("userCategory") == null ||
        !"Admin".equalsIgnoreCase((String) session.getAttribute("userCategory"))) {
        response.sendRedirect("index.jsp");
        return;
    }

    String adminName = (String) session.getAttribute("userName");
    List<Map<String, String>> notifications = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DBUtil.getConnection();

        PreparedStatement ps = con.prepareStatement("SELECT message, email, created_at FROM admin_notifications ORDER BY created_at DESC");
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Map<String, String> note = new HashMap<>();
            note.put("message", rs.getString("message"));
            note.put("email", rs.getString("email"));
            note.put("time", rs.getString("created_at"));
            notifications.add(note);
        }

        rs.close();
        ps.close();
        con.close();

    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Admin Notifications | Student Council Portal</title>
  <link rel="stylesheet" href="assets/style.css">
</head>
<body>
  <div class="dashboard-bg">
    <div class="overlay"></div>

    <div class="dashboard-container">
      <div class="dashboard-header">
        <h1>Admin Notifications</h1>
        <p>Welcome, <strong><%= adminName %></strong> — here are your recent system alerts.</p>
      </div>

      <% if (notifications.isEmpty()) { %>
        <p class="status-msg info">No new notifications 🎉</p>
      <% } else { %>
        <div class="notification-box">
          <% for (Map<String, String> n : notifications) { %>
            <p>📩 <%= n.get("message") %><br>
            <small><%= n.get("time") %> | <%= n.get("email") %></small></p>
          <% } %>
        </div>
      <% } %>

      <div style="margin-top:20px;">
        <a href="admin_dashboard.jsp" class="btn">Back to Dashboard</a>
      </div>
    </div>
  </div>
</body>
</html>
