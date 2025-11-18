<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*, jakarta.servlet.http.*" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>
<%
  HttpSession s = request.getSession(false);
  if (s == null || s.getAttribute("userCategory")==null) { response.sendRedirect("index.jsp"); return; }
  String role = ((String)s.getAttribute("userCategory"));
  String email = (String)s.getAttribute("userEmail");

  boolean canManage = "Admin".equalsIgnoreCase(role)
                   || "President".equalsIgnoreCase(role)
                   || "Vice President".equalsIgnoreCase(role)
                   || "Cultural Secretary".equalsIgnoreCase(role);

  if (!canManage) { response.sendRedirect("events.jsp"); return; }

  String msg = request.getParameter("msg")!=null?request.getParameter("msg"):"";

  // Handle POST actions: add / delete / toggle visibility
  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String act = request.getParameter("action");
    try (Connection c = DBUtil.getConnection()) {
      if ("add".equals(act)) {
        // ✅ Server-side validation for date & time
        String dateStr = request.getParameter("event_date");
        String startTimeStr = request.getParameter("start_time");
        String endTimeStr = request.getParameter("end_time");

        java.sql.Date eventDate = java.sql.Date.valueOf(dateStr);
        java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
        if (eventDate.before(today)) {
          throw new Exception("Event date cannot be in the past.");
        }

        if (startTimeStr == null || endTimeStr == null || startTimeStr.isEmpty() || endTimeStr.isEmpty()) {
          throw new Exception("Both start and end times are required.");
        }

        java.sql.Time startT = java.sql.Time.valueOf(startTimeStr + ":00");
        java.sql.Time endT = java.sql.Time.valueOf(endTimeStr + ":00");
        if (endT.before(startT) || endT.equals(startT)) {
          throw new Exception("End time must be after start time.");
        }

        // ✅ Overlap check (same date & same venue)
        // ✅ Overlap check (same date & same venue)
        try (PreparedStatement check = c.prepareStatement(
            "SELECT COUNT(*) FROM council_events WHERE event_date = ? AND venue = ? " +
            "AND ((? < end_time AND ? > start_time))")) {
          check.setDate(1, eventDate);
          check.setString(2, request.getParameter("venue"));
          check.setTime(3, startT);
          check.setTime(4, endT);
          ResultSet rs = check.executeQuery();
          if (rs.next() && rs.getInt(1) > 0) {
            throw new Exception("Another event already exists at this venue during that time.");
          }
          rs.close();
        }

        // ✅ Insert event after validation passes
        try (PreparedStatement p = c.prepareStatement(
             "INSERT INTO council_events (title, description, event_date, start_time, end_time, venue, is_visible, created_by_email, created_by_role) " +
             "VALUES (?,?,?,?,?,?,1,?,?)")) {
          p.setString(1, request.getParameter("title"));
          p.setString(2, request.getParameter("description"));
          p.setString(3, dateStr);
          p.setString(4, startTimeStr);
          p.setString(5, endTimeStr);
          p.setString(6, request.getParameter("venue"));
          p.setString(7, email);
          p.setString(8, role);
          p.executeUpdate();
        }
        response.sendRedirect("manage_events.jsp?msg=Event%20added");
        return;
      } else if ("delete".equals(act)) {
        try (PreparedStatement p = c.prepareStatement("DELETE FROM council_events WHERE id=?")) {
          p.setInt(1, Integer.parseInt(request.getParameter("id")));
          p.executeUpdate();
        }
        response.sendRedirect("manage_events.jsp?msg=Event%20deleted");
        return;
      } else if ("toggle".equals(act)) {
        try (PreparedStatement p = c.prepareStatement("UPDATE council_events SET is_visible=NOT is_visible WHERE id=?")) {
          p.setInt(1, Integer.parseInt(request.getParameter("id")));
          p.executeUpdate();
        }
        response.sendRedirect("manage_events.jsp?msg=Visibility%20updated");
        return;
      }
    } catch (Exception ex) {
      response.sendRedirect("manage_events.jsp?msg="+java.net.URLEncoder.encode("Error: "+ex.getMessage(),"UTF-8"));
      return;
    }
  }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Manage Events</title>
  <link rel="stylesheet" href="assets/style.css">
</head>
<body>
<div class="dashboard-bg">
  <div class="overlay"></div>
  <div class="dashboard-container">
    <div class="dashboard-header">
      <h1>Manage Events</h1>
      <p>You can add, delete or toggle visibility of events.</p>
    </div>

    <% if (!msg.isEmpty()) { %><p class="status-msg success"><%= msg %></p><% } %>

    <h2>Add New Event</h2>
    <form method="post" class="application-form" style="margin-bottom:20px;" id="eventForm">
      <input type="hidden" name="action" value="add">
      <div class="two-col">
        <div class="field"><label>Title</label><input class="input" name="title" required></div>
        <div class="field"><label>Venue</label><input class="input" name="venue"></div>
      </div>
      <div class="three-col">
        <div class="field"><label>Date</label><input class="input" type="date" name="event_date" required></div>
        <div class="field"><label>Start Time</label><input class="input" type="time" name="start_time" required></div>
        <div class="field"><label>End Time</label><input class="input" type="time" name="end_time" required></div>
      </div>
      <div class="field"><label>Description</label><textarea class="input" name="description"></textarea></div>
      <button class="btn" type="submit">Add Event</button>
    </form>

    <hr class="divider">
    <h2>All Events</h2>
    <div class="table-container">
      <table class="result-table">
        <tr><th>ID</th><th>Date</th><th>Time</th><th>Title</th><th>Venue</th><th>Visible</th><th>Actions</th></tr>
        <%
          try (Connection c = DBUtil.getConnection();
               PreparedStatement p = c.prepareStatement(
                 "SELECT id, title, event_date, start_time, end_time, venue, is_visible FROM council_events ORDER BY event_date DESC, id DESC");
               ResultSet r = p.executeQuery()) {
            boolean any=false;
            while (r.next()) { any=true; %>
            <tr>
              <td><%= r.getInt("id") %></td>
              <td><%= r.getDate("event_date") %></td>
              <td>
                <%= (r.getTime("start_time")!=null ? r.getTime("start_time").toString().substring(0,5) : "") %>
                <%= (r.getTime("end_time")!=null ? " - "+r.getTime("end_time").toString().substring(0,5) : "") %>
              </td>
              <td><%= r.getString("title") %></td>
              <td><%= r.getString("venue") %></td>
              <td><%= r.getBoolean("is_visible") ? "Yes" : "No" %></td>
              <td>
                <form method="post" style="display:inline;">
                  <input type="hidden" name="action" value="toggle">
                  <input type="hidden" name="id" value="<%= r.getInt("id") %>">
                  <button class="btn" type="submit"><%= r.getBoolean("is_visible") ? "Hide" : "Show" %></button>
                </form>
                <form method="post" style="display:inline;margin-left:6px;">
                  <input type="hidden" name="action" value="delete">
                  <input type="hidden" name="id" value="<%= r.getInt("id") %>">
                  <button class="btn" type="submit">Delete</button>
                </form>
              </td>
            </tr>
        <%  }
            if (!any) out.println("<tr><td colspan='7'>No events yet.</td></tr>");
          } catch (Exception ex) {
            out.println("<tr><td colspan='7'>Error: "+ex.getMessage()+"</td></tr>");
          }
        %>
      </table>
    </div>

    <div class="back-btn-container">
      <a href="admin_dashboard.jsp" class="btn">Back to Dashboard</a>
    </div>
  </div>
</div>

<!-- ✅ Frontend validation -->
<script>
  const dateInput = document.querySelector('input[name="event_date"]');
  const startTime = document.querySelector('input[name="start_time"]');
  const endTime = document.querySelector('input[name="end_time"]');

  // ✅ Disable past dates
  const today = new Date();
  const yyyy = today.getFullYear();
  const mm = String(today.getMonth() + 1).padStart(2, '0');
  const dd = String(today.getDate()).padStart(2, '0');
  dateInput.min = `${yyyy}-${mm}-${dd}`;

  // ✅ Helper to format time as HH:MM
  function formatTime(date) {
    return date.toTimeString().slice(0, 5);
  }

  // ✅ When date changes, update available times
  dateInput.addEventListener("change", () => {
    const selectedDate = new Date(dateInput.value);
    const now = new Date();

    // If user picks today → restrict start times to after current time
    if (selectedDate.toDateString() === now.toDateString()) {
      const currentTime = formatTime(now);
      startTime.min = currentTime;
    } else {
      // For future dates → all times are valid
      startTime.removeAttribute("min");
      endTime.removeAttribute("min");
    }

    // Clear any previously chosen invalid values
    if (startTime.value && startTime.min && startTime.value < startTime.min) {
      startTime.value = "";
    }
    if (endTime.value && endTime.min && endTime.value < endTime.min) {
      endTime.value = "";
    }
  });

  // ✅ When start time changes → restrict end time
  startTime.addEventListener("change", () => {
    if (!startTime.value) return;
    endTime.min = startTime.value;

    // If the date is today, and current time > start time, fix it
    const selectedDate = new Date(dateInput.value);
    const now = new Date();
    if (selectedDate.toDateString() === now.toDateString()) {
      const currentTime = formatTime(now);
      if (startTime.value < currentTime) {
        alert("Start time must be in the future for today's date.");
        startTime.value = "";
        return;
      }
    }

    // Clear invalid end time
    if (endTime.value && endTime.value < endTime.min) {
      alert("End time must be after the start time!");
      endTime.value = "";
    }
  });

  // ✅ When end time changes, revalidate against start time
  endTime.addEventListener("change", () => {
    if (endTime.value && startTime.value && endTime.value <= startTime.value) {
      alert("End time must be after start time!");
      endTime.value = "";
    }
  });

  // ✅ On form submit double-check all constraints
  document.getElementById("eventForm").addEventListener("submit", (e) => {
    const selectedDate = new Date(dateInput.value);
    const now = new Date();

    if (selectedDate < new Date(yyyy, today.getMonth(), today.getDate())) {
      e.preventDefault();
      alert("Event date cannot be in the past!");
      return;
    }

    if (!startTime.value || !endTime.value) {
      e.preventDefault();
      alert("Please select valid start and end times.");
      return;
    }

    if (selectedDate.toDateString() === now.toDateString()) {
      const currentTime = formatTime(now);
      if (startTime.value <= currentTime) {
        e.preventDefault();
        alert("Start time must be later than the current time for today's date.");
        return;
      }
    }

    if (endTime.value <= startTime.value) {
      e.preventDefault();
      alert("End time must be after start time!");
    }
  });
</script>

</body>
</html>
