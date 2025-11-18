<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, jakarta.servlet.http.*" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userCategory") == null ||
        !"Admin".equalsIgnoreCase((String)userSession.getAttribute("userCategory"))) {
        response.sendRedirect("index.jsp");
        return;
    }

    String message = request.getParameter("msg") != null ? request.getParameter("msg") : "";
    String selectedEmail = request.getParameter("studentEmail");
    String userName = (String) userSession.getAttribute("userName");

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>View Applications | Admin Dashboard</title>
    <link rel="stylesheet" href="assets/style.css">
</head>
<body>
<div class="dashboard-bg">
    <div class="overlay"></div>

    <div class="dashboard-container">
        <div class="dashboard-header">
            <h1>View Student Applications</h1>
            <p>Welcome, <strong><%= userName %></strong> — review and manage all council applications.</p>
        </div>

        <% if (!message.isEmpty()) { %>
            <p class="status-msg success"><%= message %></p>
        <% } %>

        <!-- Student selection dropdown -->
        <form method="get" class="application-form" style="margin-bottom: 20px;">
            <label>Select Student:</label>
            <select name="studentEmail" class="input" required onchange="this.form.submit()">
                <option value="">-- Choose a student --</option>
                <%
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        con = DBUtil.getConnection();

                        ps = con.prepareStatement("SELECT emailid, firstname, lastname, status FROM application_table ORDER BY firstname ASC");
                        rs = ps.executeQuery();

                        while (rs.next()) {
                            String email = rs.getString("emailid");
                            String fullName = rs.getString("firstname") + " " + rs.getString("lastname");
                            String status = rs.getString("status");

                            String displayStatus = status != null ? status : "Pending";
                            String color = "color:white;"; // fallback

                            if ("Approved".equalsIgnoreCase(displayStatus)) {
                                color = "color:lightgreen;";
                            } else if ("Rejected".equalsIgnoreCase(displayStatus)) {
                                color = "color:tomato;";
                            } else if ("Pending".equalsIgnoreCase(displayStatus)) {
                                color = "color:khaki;";
                            }
                %>
                    <option value="<%= email %>" 
                        style="<%= color %>" 
                        <%= email.equals(selectedEmail) ? "selected" : "" %>>
                        <%= fullName %> (<%= email %>) — <%= displayStatus %>
                    </option>
                <%
                        }
                        rs.close();
                        ps.close();
                    } catch (Exception e) {
                        out.println("<p class='status-msg error'>Error fetching students: " + e.getMessage() + "</p>");
                    }
                %>
            </select>
        </form>

        <% if (selectedEmail != null && !selectedEmail.trim().isEmpty()) {
            try {
                ps = con.prepareStatement("SELECT * FROM application_table WHERE emailid = ?");
                ps.setString(1, selectedEmail);
                rs = ps.executeQuery();

                if (rs.next()) {
        %>
                    <div class="application-card">
                        <h2><%= rs.getString("firstname") %> <%= rs.getString("lastname") %></h2>
                        <p><strong>Email:</strong> <%= rs.getString("emailid") %></p>
                        <p><strong>Class:</strong> <%= rs.getString("class") %></p>
                        <p><strong>House:</strong> <%= rs.getString("house") %></p>
                        <p><strong>Gender:</strong> <%= rs.getString("gender") %></p>
                        <p><strong>Position 1:</strong> <%= rs.getString("position1") %></p>
                        <p><strong>Position 2:</strong> <%= rs.getString("position2") %></p>
                        <p><strong>Position 3:</strong> <%= rs.getString("position3") %></p>
                        <p><strong>Achievements:</strong> <%= rs.getString("achievement") %></p>
                        <p><strong>Reflection:</strong> <%= rs.getString("reflection") %></p>
                        <p><strong>Status:</strong> 
                            <span class="status-label <%= rs.getString("status").toLowerCase() %>">
                                <%= rs.getString("status") %>
                            </span>
                        </p>

                        <div class="action-buttons">
                            <form method="post" action="update_status.jsp" style="display:inline;">
                                <input type="hidden" name="studentEmail" value="<%= selectedEmail %>">
                                <input type="hidden" name="action" value="shortlist">
                                <button type="submit" class="btn">Approve</button>
                            </form>

                            <form method="post" action="update_status.jsp" style="display:inline;">
                                <input type="hidden" name="studentEmail" value="<%= selectedEmail %>">
                                <input type="hidden" name="action" value="reject">
                                <button type="submit" class="btn danger">Reject</button>
                            </form>
                        </div>
                    </div>
        <%
                } else {
                    out.println("<p class='status-msg error'>No record found for this student.</p>");
                }
            } catch (Exception e) {
                out.println("<p class='status-msg error'>Error loading application: " + e.getMessage() + "</p>");
            } finally {
                try { if (rs != null) rs.close(); } catch (Exception ignored) {}
                try { if (ps != null) ps.close(); } catch (Exception ignored) {}
                try { if (con != null) con.close(); } catch (Exception ignored) {}
            }
        } %>
    </div>
</div>
</body>
</html>
