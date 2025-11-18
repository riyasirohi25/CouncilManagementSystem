<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, jakarta.servlet.http.*, java.text.SimpleDateFormat" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userCategory") == null ||
        !"Student".equalsIgnoreCase((String)userSession.getAttribute("userCategory"))) {
        response.sendRedirect("index.jsp");
        return;
    }

    String email = (String) userSession.getAttribute("userEmail");
    String message = request.getParameter("msg") != null ? request.getParameter("msg") : "";

    int appID = 0;
    String post = "", date = "", venue = "", confirmedTime = "";
    java.util.List<String> availableTimes = new java.util.ArrayList<>();
    java.util.List<String> takenTimes = new java.util.ArrayList<>();

    // Helper to format time into AM/PM format
    java.util.function.Function<Time, String> formatTime = (t) -> {
        if (t == null) return null;
        SimpleDateFormat sdf = new SimpleDateFormat("hh:mm a");
        return sdf.format(t);
    };

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DBUtil.getConnection();

        // ✅ Get student's applicationID
        PreparedStatement ps1 = con.prepareStatement("SELECT applicationID FROM application_table WHERE emailid = ?");
        ps1.setString(1, email);
        ResultSet rs1 = ps1.executeQuery();
        if (rs1.next()) {
            appID = rs1.getInt("applicationID");
        }
        rs1.close();
        ps1.close();

        // ✅ Get interview details
        if (appID > 0) {
            PreparedStatement ps2 = con.prepareStatement("SELECT * FROM interview_table WHERE applicationID = ?");
            ps2.setInt(1, appID);
            ResultSet rs2 = ps2.executeQuery();

            if (rs2.next()) {
                post = rs2.getString("post");
                date = rs2.getString("date");
                venue = rs2.getString("venue");

                Time t1 = rs2.getTime("time1");
                Time t2 = rs2.getTime("time2");
                Time t3 = rs2.getTime("time3");
                Time selected = rs2.getTime("confirmed_time");

                if (selected != null) {
                    confirmedTime = formatTime.apply(selected);
                }

                // ✅ Get all taken slots for the same post and date
                PreparedStatement taken = con.prepareStatement(
                    "SELECT confirmed_time FROM interview_table WHERE post = ? AND date = ? AND confirmed_time IS NOT NULL"
                );
                taken.setString(1, post);
                taken.setString(2, date);
                ResultSet takenRs = taken.executeQuery();
                java.util.Set<String> takenSet = new java.util.HashSet<>();
                while (takenRs.next()) {
                    Time t = takenRs.getTime("confirmed_time");
                    if (t != null) takenSet.add(formatTime.apply(t));
                }
                takenRs.close();
                taken.close();

                // ✅ Add available + mark taken
                if (t1 != null) {
                    String ft = formatTime.apply(t1);
                    if (takenSet.contains(ft)) takenTimes.add(ft);
                    else availableTimes.add(ft);
                }
                if (t2 != null) {
                    String ft = formatTime.apply(t2);
                    if (takenSet.contains(ft)) takenTimes.add(ft);
                    else availableTimes.add(ft);
                }
                if (t3 != null) {
                    String ft = formatTime.apply(t3);
                    if (takenSet.contains(ft)) takenTimes.add(ft);
                    else availableTimes.add(ft);
                }
            }
            rs2.close();
            ps2.close();
        }

        con.close();

    } catch (Exception e) {
        out.println("<p class='status-msg error'>Error loading interview details: " + e.getMessage() + "</p>");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Interview Schedule | Student Dashboard</title>
    <link rel="stylesheet" href="assets/style.css">
    <style>
        .taken-option {
            color: #aaa;
            background-color: #f5f5f5;
            text-decoration: line-through;
        }
    </style>
</head>
<body>
<div class="dashboard-bg">
    <div class="overlay"></div>

    <div class="dashboard-container">
        <div class="dashboard-header">
            <h1>Interview Schedule</h1>
            <p>Your scheduled interview details are shown below.</p>
        </div>

        <% if (!message.isEmpty()) { %>
            <p class="status-msg success"><%= message %></p>
        <% } %>

        <% if (appID == 0) { %>
            <p class="status-msg error">You have not submitted any council application yet.</p>
        <% } else if (post.isEmpty()) { %>
            <p class="status-msg error">Interview not scheduled yet. Please wait for admin update.</p>
        <% } else { %>
            <div class="application-form">
                <p><strong>Post:</strong> <%= post %></p>
                <p><strong>Date:</strong> <%= date %></p>
                <p><strong>Venue:</strong> <%= venue %></p>

                <% if (confirmedTime != null && !confirmedTime.isEmpty()) { %>
                    <p class="status-msg success"><strong>Your Confirmed Interview Slot:</strong> <%= confirmedTime %></p>
                <% } else { %>
                    <form method="post" action="update_interview_slot.jsp" class="application-form">
                        <input type="hidden" name="applicationID" value="<%= appID %>">

                        <label><strong>Select Preferred Time Slot:</strong></label>
                        <select name="selectedSlot" class="input" required>
                            <option value="">Select</option>
                            <% 
                                for (String t : availableTimes) { 
                            %>
                                <option value="<%= t %>"><%= t %></option>
                            <% } 
                                for (String t : takenTimes) {
                            %>
                                <option value="<%= t %>" disabled class="taken-option"><%= t %> (Taken)</option>
                            <% } %>
                        </select>

                        <button type="submit" class="btn" style="margin-top:20px;">Confirm Slot</button>
                    </form>
                <% } %>
            </div>
        <% } %>
    </div>
</div>
</body>
</html>
