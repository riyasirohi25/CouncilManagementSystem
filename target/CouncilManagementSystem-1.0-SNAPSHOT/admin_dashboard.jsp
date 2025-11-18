<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="jakarta.servlet.http.*"%>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userCategory") == null ||
        !"Admin".equalsIgnoreCase((String)userSession.getAttribute("userCategory"))) {
        response.sendRedirect("index.jsp");
        return;
    }

    String userName = (String)userSession.getAttribute("userName");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Admin Dashboard | Student Council Portal</title>
  <link rel="stylesheet" href="assets/style.css">
</head>
<body>
  <div class="dashboard-bg">
    <div class="overlay"></div>

    <div class="dashboard-container">
      <div class="dashboard-header">
        <h1>Admin Dashboard</h1>
        <p>Welcome, <strong><%= userName %></strong> — manage student council applications and interviews.</p>
      </div>

      <div class="dashboard-grid">
        <a href="admin_view_application.jsp" class="dashboard-btn">View Applications</a>
        <a href="schedule_interviews.jsp" class="dashboard-btn">Schedule Interviews</a>
        <a href="view_interviews.jsp" class="dashboard-btn">View Scheduled Interviews</a>
        <a href="declare_results.jsp" class="dashboard-btn">Declare Results</a>
        <a href="admin_verify_students.jsp" class="dashboard-btn">Verify Students/ Admins</a>
        <a href="admin_notifications.jsp" class="dashboard-btn">View Notifications</a>
        <a href="ManageProfile.jsp" class="dashboard-btn">Manage Profile</a>
        <a href="manage_events.jsp" class="dashboard-btn">Manage Events</a>
        <a href="reset_system.jsp" class="dashboard-btn"> Reset System for New Session</a>

        <a href="LogoutServlet" class="dashboard-btn logout">Logout</a>
      </div>
    </div>
  </div>
</body>
</html>
