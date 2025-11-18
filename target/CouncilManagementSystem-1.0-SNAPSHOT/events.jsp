<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Upcoming Council Events</title>
  <link rel="stylesheet" href="assets/style.css">
</head>
<body>
<div class="dashboard-bg">
  <div class="overlay"></div>
  <div class="dashboard-container">
    <div class="dashboard-header">
      <h1>Upcoming Council Events</h1>
      <p>Stay updated with what’s happening.</p>
    </div>

    <div class="table-container">
      <table class="result-table">
        <tr><th>Date</th><th>Time</th><th>Title</th><th>Venue</th><th>Details</th></tr>
        <%
          try (Connection c = DBUtil.getConnection();
               PreparedStatement p = c.prepareStatement(
                 "SELECT title, description, event_date, start_time, end_time, venue " +
                 "FROM council_events WHERE is_visible=1 AND event_date >= CURDATE() " +
                 "ORDER BY event_date ASC, COALESCE(start_time,'00:00:00') ASC")) {
              try (ResultSet r = p.executeQuery()) {
                boolean any = false;
                while (r.next()) {
                  any = true;
        %>
          <tr>
            <td><%= r.getDate("event_date") %></td>
            <td>
              <%= (r.getTime("start_time")!=null ? r.getTime("start_time").toString().substring(0,5) : "") %>
              <%= (r.getTime("end_time")!=null ? " - "+r.getTime("end_time").toString().substring(0,5) : "") %>
            </td>
            <td><%= r.getString("title") %></td>
            <td><%= r.getString("venue")!=null ? r.getString("venue") : "" %></td>
            <td><%= r.getString("description")!=null ? r.getString("description") : "" %></td>
          </tr>
        <%
                }
                if (!any) { out.println("<tr><td colspan='5'>No upcoming events.</td></tr>"); }
              }
          } catch (Exception ex) {
            out.println("<tr><td colspan='5'>Error: "+ex.getMessage()+"</td></tr>");
          }
        %>
      </table>
    </div>

    <div class="back-btn-container">
      <a href="index.jsp" class="btn">Back</a>
    </div>
  </div>
</div>
</body>
</html>
