<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="jakarta.servlet.http.*, java.sql.*, java.time.*, java.time.temporal.ChronoUnit"%>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userCategory") == null ||
        !"Student".equalsIgnoreCase((String)userSession.getAttribute("userCategory"))) {
        response.sendRedirect("index.jsp");
        return;
    }

    String userName = (String)userSession.getAttribute("userName");
    String email = (String)userSession.getAttribute("userEmail");

    boolean hasApplied = false;
    boolean canEdit = false;
    long remainingHours = 0;
    long remainingMinutes = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DBUtil.getConnection();

        PreparedStatement ps = con.prepareStatement(
            "SELECT MIN(TIMESTAMP(dateSubmission, timeSubmission)) AS first_ts FROM application_table WHERE emailid = ?"
        );
        ps.setString(1, email);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            Timestamp firstTs = rs.getTimestamp("first_ts");
            if (firstTs != null) {
                hasApplied = true;
                LocalDateTime firstSubmittedAt = firstTs.toLocalDateTime();
                LocalDateTime now = LocalDateTime.now();

                long minutesPassed = ChronoUnit.MINUTES.between(firstSubmittedAt, now);
                if (minutesPassed < 24L * 60L) {
                    canEdit = true;
                    long totalMinutesRemaining = 24L * 60L - minutesPassed;
                    remainingHours = totalMinutesRemaining / 60L;
                    remainingMinutes = totalMinutesRemaining % 60L;
                }
            }
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
  <title>Student Dashboard | Student Council Portal</title>
  <link rel="stylesheet" href="assets/style.css">
</head>
<body>
  <div class="dashboard-bg">
    <div class="dashboard-overlay"></div>

    <div class="dashboard-container">
      <div class="dashboard-header">
        <h1>Student Dashboard</h1>
        <p>Hello, <strong><%= userName %></strong> — manage your council application and interviews here.</p>
      </div>

      <div class="dashboard-grid">
        <!-- Apply for Council -->
        <div class="dashboard-item">
          <% if (hasApplied) { %>
            <button class="dashboard-btn disabled-btn" disabled>Apply for Council</button>
          <% } else { %>
            <a href="application.jsp" class="dashboard-btn">Apply for Council</a>
          <% } %>
        </div>

        <!-- Edit Application -->
        <div class="dashboard-item">
          <% if (!hasApplied) { %>
            <button class="dashboard-btn disabled-btn" disabled>Edit Application</button>
          <% } else if (canEdit) { %>
            <a href="edit_application.jsp" class="dashboard-btn">Edit Application</a>
            <p class="edit-timer">You can edit for another <%= remainingHours %>h <%= remainingMinutes %>m</p>
          <% } else { %>
            <button class="dashboard-btn disabled-btn" disabled>Edit Locked (24 hrs Passed)</button>
          <% } %>
        </div>

        <!-- View Application -->
        <div class="dashboard-item">
          <% if (hasApplied) { %>
            <a href="view_application.jsp" class="dashboard-btn">View Application</a>
          <% } else { %>
            <button class="dashboard-btn disabled-btn" disabled>View Application</button>
          <% } %>
        </div>

        <!-- View Interview Slot -->
        <div class="dashboard-item">
          <a href="interview_schedule.jsp" class="dashboard-btn">View Interview Slot</a>
        </div>
        
        <div class="dashboard-item">
            <a href="view_result.jsp" class="dashboard-btn">View Result</a>
        </div>
        
        <div class="dashboard-item">
            <a href="ManageProfile.jsp" class="dashboard-btn">Manage Profile</a>
        </div>
        
        <div class="dashboard-item">
            <a href="events.jsp" class="dashboard-btn">View Events</a>
        </div>

        <!-- Logout -->
        <div class="dashboard-item">
          <a href="LogoutServlet" class="dashboard-btn logout">Logout</a>
        </div>
        
        
      
      </div>
    </div>
  </div>
</body>
</html>
