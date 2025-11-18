<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.time.format.DateTimeFormatter, jakarta.servlet.http.*" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userCategory") == null || !"Student".equalsIgnoreCase((String)sess.getAttribute("userCategory"))) {
        response.sendRedirect("index.jsp");
        return;
    }

    String email = (String) sess.getAttribute("userEmail");
    String firstName = "", lastName = "", house = "", className = "";
    String pos1 = "", pos2 = "", pos3 = "", achievements = "", reflection = "", appStatus = "Pending";
    String errorMsg = "", submissionDateTime = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DBUtil.getConnection();

        PreparedStatement ps = con.prepareStatement("SELECT * FROM application_table WHERE emailid = ?");
        ps.setString(1, email);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            firstName = rs.getString("firstname");
            lastName = rs.getString("lastname");
            house = rs.getString("house");
            className = rs.getString("class");
            pos1 = rs.getString("position1");
            pos2 = rs.getString("position2");
            pos3 = rs.getString("position3");
            achievements = rs.getString("achievement");
            reflection = rs.getString("reflection");
            appStatus = rs.getString("status");

            java.sql.Date date = rs.getDate("dateSubmission");
            java.sql.Time time = rs.getTime("timeSubmission");
            if (date != null && time != null) {
                java.time.LocalDateTime submittedAt = java.time.LocalDateTime.of(date.toLocalDate(), time.toLocalTime());
                submissionDateTime = submittedAt.format(DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a"));
            }
        } else {
            errorMsg = "No application found.";
        }

        rs.close();
        ps.close();
        con.close();
    } catch (Exception e) {
        errorMsg = "Error fetching application: " + e.getMessage();
    }

    String statusColor = "var(--muted)";
    if ("Accepted".equalsIgnoreCase(appStatus)) statusColor = "var(--success)";
    else if ("Rejected".equalsIgnoreCase(appStatus)) statusColor = "var(--error)";
%>

<!DOCTYPE html>
<html>
<head>
    <title>View Application</title>
    <link rel="stylesheet" href="assets/style.css">
</head>
<body>
<div class="dashboard-bg">
  <div class="overlay"></div>
  <div class="dashboard-container">
    <div class="dashboard-header">
      <h1>Your Application Details</h1>
      <p>Below are the details of your submitted application.</p>
    </div>

    <% if (!errorMsg.isEmpty()) { %>
      <p class="status-msg error"><%= errorMsg %></p>
    <% } else { %>
      <div style="text-align:center; margin-bottom: 15px;">
        <p class="status-msg" style="color:<%= statusColor %>;">Status: <strong><%= appStatus %></strong></p>
        <% if (!submissionDateTime.isEmpty()) { %>
          <p class="status-msg" style="color: var(--muted); font-size:13px;">Submitted on: <%= submissionDateTime %></p>
        <% } %>
      </div>

      <div class="application-form">
        <div class="two-col">
          <div class="field"><label>First Name</label><input class="input" value="<%= firstName %>" readonly></div>
          <div class="field"><label>Last Name</label><input class="input" value="<%= lastName %>" readonly></div>
        </div>

        <div class="three-col">
          <div class="field"><label>Email</label><input class="input" value="<%= email %>" readonly></div>
          <div class="field"><label>Class</label><input class="input" value="Class <%= className %>" readonly></div>
          <div class="field"><label>House</label><input class="input" value="<%= house %>" readonly></div>
        </div>

        <div class="field">
          <label>Positions Applied</label>
          <input class="input" readonly value="<%= pos1 + ", " + pos2 + ", " + pos3 %>">
        </div>

        <div class="field">
          <label>Achievements</label>
          <textarea class="input" readonly><%= achievements %></textarea>
        </div>

        <div class="field">
          <label>Reflection</label>
          <textarea class="input" readonly><%= reflection %></textarea>
        </div>

        <div class="back-btn-container">
          <a href="student_dashboard.jsp" class="btn">Back to Dashboard</a>
        </div>
      </div>
    <% } %>
  </div>
</div>
</body>
</html>
