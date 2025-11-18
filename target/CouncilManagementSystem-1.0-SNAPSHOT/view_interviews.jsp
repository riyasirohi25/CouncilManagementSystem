<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, jakarta.servlet.http.*, java.text.SimpleDateFormat" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userCategory") == null ||
        !"Admin".equalsIgnoreCase((String)userSession.getAttribute("userCategory"))) {
        response.sendRedirect("index.jsp");
        return;
    }

    String userName = (String) userSession.getAttribute("userName");
    String message = request.getParameter("msg") != null ? request.getParameter("msg") : "";

    String searchName = request.getParameter("searchName") != null ? request.getParameter("searchName").trim() : "";
    String filterDate = request.getParameter("filterDate") != null ? request.getParameter("filterDate").trim() : "";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>View Scheduled Interviews | Admin Dashboard</title>
    <link rel="stylesheet" href="assets/style.css">
</head>

<body>
<div class="dashboard-bg">
    <div class="overlay"></div>
    <div class="dashboard-container">
        <div class="dashboard-header">
            <h1>Scheduled Interviews</h1>
            <p>Welcome, <strong><%= userName %></strong> — manage and monitor all scheduled interviews.</p>
        </div>

        <% if (!message.isEmpty()) { %>
            <p class="status-msg success"><%= message %></p>
        <% } %>

        <!-- 🔍 FILTER BAR -->
        <form method="get" class="filter-bar">
            <input type="text" name="searchName" placeholder="Search by Name" value="<%= searchName %>">
            <input type="date" name="filterDate" value="<%= filterDate %>">
            <button type="submit">Filter</button>
            <a href="view_interviews.jsp" class="reset-link">
                <button type="button">Reset</button>
            </a>
        </form>

        <table class="interview-table">
            <thead>
                <tr>
                    <th>Application ID</th>
                    <th>Name</th>
                    <th>Post</th>
                    <th>Date</th>
                    <th>Time Slot 1</th>
                    <th>Time Slot 2</th>
                    <th>Time Slot 3</th>
                    <th>Confirmed Time</th>
                    <th>Venue</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <%
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        con = DBUtil.getConnection();

                        String baseQuery = "SELECT * FROM interview_table WHERE 1=1";
                        if (!searchName.isEmpty()) baseQuery += " AND name LIKE ?";
                        if (!filterDate.isEmpty()) baseQuery += " AND date = ?";
                        baseQuery += " ORDER BY date ASC";

                        ps = con.prepareStatement(baseQuery);

                        int paramIndex = 1;
                        if (!searchName.isEmpty()) ps.setString(paramIndex++, "%" + searchName + "%");
                        if (!filterDate.isEmpty()) ps.setString(paramIndex++, filterDate);

                        rs = ps.executeQuery();

                        SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");
                        boolean hasResults = false;

                        while (rs.next()) {
                            hasResults = true;
                            int appID = rs.getInt("applicationID");
                            String name = rs.getString("name");
                            String post = rs.getString("post");
                            String date = rs.getString("date");
                            String venue = rs.getString("venue");

                            Time t1 = rs.getTime("time1");
                            Time t2 = rs.getTime("time2");
                            Time t3 = rs.getTime("time3");
                            Time confirmed = rs.getTime("confirmed_time");

                            String sT1 = (t1 != null) ? timeFmt.format(t1) : "-";
                            String sT2 = (t2 != null) ? timeFmt.format(t2) : "-";
                            String sT3 = (t3 != null) ? timeFmt.format(t3) : "-";
                            String sConfirmed = (confirmed != null) ? timeFmt.format(confirmed) : "-";

                            String status = (confirmed != null) ? "Confirmed" : "Pending";
                            String statusClass = (confirmed != null) ? "confirmed" : "pending";
                %>
                <tr>
                    <td><%= appID %></td>
                    <td><%= name %></td>
                    <td><%= post %></td>
                    <td><%= date %></td>
                    <td><%= sT1 %></td>
                    <td><%= sT2 %></td>
                    <td><%= sT3 %></td>
                    <td><%= sConfirmed %></td>
                    <td><%= venue %></td>
                    <td class="<%= statusClass %>"><%= status %></td>
                </tr>
                <%
                        }

                        if (!hasResults) {
                            out.println("<tr><td colspan='10' class='status-msg error'>No interviews found for the selected filters.</td></tr>");
                        }

                        rs.close();
                        ps.close();
                        con.close();
                    } catch (Exception e) {
                        out.println("<tr><td colspan='10' class='status-msg error'>Error loading interview data: " + e.getMessage() + "</td></tr>");
                    }
                %>
            </tbody>
        </table>

        <div class="back-btn-container">
            <a href="admin_dashboard.jsp" class="btn">⬅ Back to Dashboard</a>
        </div>
    </div>
</div>
</body>
</html>
