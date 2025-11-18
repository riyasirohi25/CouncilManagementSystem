<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*, jakarta.servlet.http.*" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>

<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userCategory") == null ||
        !"Admin".equalsIgnoreCase((String) userSession.getAttribute("userCategory"))) {
        response.sendRedirect("index.jsp");
        return;
    }

    String adminName = (String) userSession.getAttribute("userName");
    String message = "", error = "";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    List<Map<String, String>> unverifiedStudents = new ArrayList<>();
    List<Map<String, String>> unverifiedAdmins = new ArrayList<>();
    List<Map<String, String>> notifications = new ArrayList<>();

    try {
        con = DBUtil.getConnection();

        // ✅ Ensure notifications table exists
        Statement st = con.createStatement();
        st.executeUpdate(
            "CREATE TABLE IF NOT EXISTS admin_notifications (" +
            "id INT AUTO_INCREMENT PRIMARY KEY, " +
            "message VARCHAR(255), " +
            "email VARCHAR(100) UNIQUE, " +
            "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)"
        );
        st.close();

        // ✅ Handle verification (students + admins)
        String verifyEmail = request.getParameter("verify");
        if (verifyEmail != null && !verifyEmail.isEmpty()) {
            ps = con.prepareStatement("UPDATE login_table SET isVerified = 1 WHERE emailid = ?");
            ps.setString(1, verifyEmail);
            int rows = ps.executeUpdate();
            ps.close();

            if (rows > 0) {
                message = "User with email " + verifyEmail + " has been verified successfully.";

                // Delete corresponding notification
                PreparedStatement del = con.prepareStatement("DELETE FROM admin_notifications WHERE email = ?");
                del.setString(1, verifyEmail);
                del.executeUpdate();
                del.close();
            } else {
                error = "No user found or already verified.";
            }
        }

        // ✅ Fetch unverified students
        ps = con.prepareStatement("SELECT firstname, lastname, emailid FROM login_table WHERE category='Student' AND isVerified=0");
        rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, String> s = new HashMap<>();
            s.put("firstname", rs.getString("firstname"));
            s.put("lastname", rs.getString("lastname"));
            s.put("emailid", rs.getString("emailid"));
            unverifiedStudents.add(s);
        }
        rs.close();
        ps.close();

        // ✅ Fetch unverified admins
        ps = con.prepareStatement("SELECT firstname, lastname, emailid FROM login_table WHERE category='Admin' AND isVerified=0");
        rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, String> a = new HashMap<>();
            a.put("firstname", rs.getString("firstname"));
            a.put("lastname", rs.getString("lastname"));
            a.put("emailid", rs.getString("emailid"));
            unverifiedAdmins.add(a);
        }
        rs.close();
        ps.close();

        // ✅ Fetch pending notifications (one per unverified user)
        ps = con.prepareStatement("SELECT message, email, created_at FROM admin_notifications ORDER BY created_at DESC");
        rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, String> n = new HashMap<>();
            n.put("message", rs.getString("message"));
            n.put("email", rs.getString("email"));
            n.put("time", rs.getString("created_at"));
            notifications.add(n);
        }

        rs.close();
        ps.close();
        con.close();

    } catch (Exception e) {
        error = e.getMessage();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Verify Users | Admin Dashboard</title>
  <link rel="stylesheet" href="assets/style.css">
  <style>
    .notif-count {
      font-weight: bold;
      color: #2a7ae2;
      margin-bottom: 5px;
    }
    .notification-box p {
      background: rgba(255,255,255,0.1);
      padding: 10px;
      border-radius: 8px;
      margin: 6px 0;
      font-size: 14px;
    }
  </style>
</head>
<body>
<div class="dashboard-bg">
  <div class="overlay"></div>

  <div class="dashboard-container">
    <div class="dashboard-header">
      <h1>User Verification</h1>
      <p>Welcome, <strong><%= adminName %></strong> — verify pending student and admin registrations.</p>
    </div>

    <% if (!error.isEmpty()) { %>
      <p class="status-msg error"><%= error %></p>
    <% } else if (!message.isEmpty()) { %>
      <p class="status-msg success"><%= message %></p>
    <% } %>

    <!-- 🔔 Pending Notifications -->
    <% if (!notifications.isEmpty()) { %>
      <h2>Pending Registration Notifications</h2>
      <p class="notif-count">Total Pending: <%= notifications.size() %></p>
      <div class="notification-box">
        <% for (Map<String,String> note : notifications) { %>
          <p>📩 <%= note.get("message") %><br><small><%= note.get("time") %></small></p>
        <% } %>
      </div>
    <% } else { %>
      <p class="status-msg info">No new registration notifications ✅</p>
    <% } %>

    <!-- 👩‍🎓 Unverified Students -->
    <h2 style="margin-top:25px;">Unverified Students</h2>
    <% if (unverifiedStudents.isEmpty()) { %>
      <p class="status-msg info">All students are verified ✅</p>
    <% } else { %>
      <table class="result-table">
        <tr><th>Name</th><th>Email</th><th>Action</th></tr>
        <% for (Map<String,String> s : unverifiedStudents) { %>
          <tr>
            <td><%= s.get("firstname") %> <%= s.get("lastname") %></td>
            <td><%= s.get("emailid") %></td>
            <td>
              <form method="post" style="display:inline;">
                <input type="hidden" name="verify" value="<%= s.get("emailid") %>">
                <button type="submit" class="btn">Verify</button>
              </form>
            </td>
          </tr>
        <% } %>
      </table>
    <% } %>

    <!-- 🧑‍💼 Unverified Admins -->
    <h2 style="margin-top:25px;">Unverified Admins</h2>
    <% if (unverifiedAdmins.isEmpty()) { %>
      <p class="status-msg info">All admins are verified ✅</p>
    <% } else { %>
      <table class="result-table">
        <tr><th>Name</th><th>Email</th><th>Action</th></tr>
        <% for (Map<String,String> a : unverifiedAdmins) { %>
          <tr>
            <td><%= a.get("firstname") %> <%= a.get("lastname") %></td>
            <td><%= a.get("emailid") %></td>
            <td>
              <form method="post" style="display:inline;">
                <input type="hidden" name="verify" value="<%= a.get("emailid") %>">
                <button type="submit" class="btn">Verify</button>
              </form>
            </td>
          </tr>
        <% } %>
      </table>
    <% } %>

    <div style="margin-top:30px;">
      <a href="admin_dashboard.jsp" class="btn">Back to Dashboard</a>
    </div>
  </div>
</div>
</body>
</html>
