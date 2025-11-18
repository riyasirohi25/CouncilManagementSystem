<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, jakarta.servlet.http.*, java.time.*, java.text.SimpleDateFormat" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>

<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userCategory") == null ||
        !"Admin".equalsIgnoreCase((String)userSession.getAttribute("userCategory"))) {
        response.sendRedirect("index.jsp");
        return;
    }

    String userName = (String) userSession.getAttribute("userName");
    String selectedEmail = request.getParameter("studentEmail");
    String message = request.getParameter("msg") != null ? request.getParameter("msg") : "";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Schedule Interviews | Admin Dashboard</title>
    <link rel="stylesheet" href="assets/style.css">
    <style>
        .taken-slot { color: gray; background-color: #f3f3f3; text-decoration: line-through; }
    </style>
</head>
<body>
<div class="dashboard-bg">
    <div class="overlay"></div>
    <div class="dashboard-container">
        <div class="dashboard-header">
            <h1>Schedule Interview</h1>
            <p>Welcome, <strong><%= userName %></strong> — assign interview slots for approved students.</p>
        </div>

        <% if (!message.isEmpty()) { %>
            <p class="status-msg success"><%= message %></p>
        <% } %>

        <!-- Student selection dropdown -->
        <form method="get" class="application-form" style="margin-bottom: 20px;">
            <label><strong>Select Student:</strong></label>
            <select name="studentEmail" class="input" required onchange="this.form.submit()">
                <option value="">-- Choose an approved student --</option>
                <%
                    try (Connection con = DBUtil.getConnection();
                         PreparedStatement ps = con.prepareStatement(
                             "SELECT applicationID, firstname, lastname, emailid, status " +
                             "FROM application_table WHERE status = 'Approved' ORDER BY firstname ASC");
                         ResultSet rs = ps.executeQuery()) {

                        boolean anyApproved = false;
                        while (rs.next()) {
                            anyApproved = true;
                            String email = rs.getString("emailid");
                            String fullName = rs.getString("firstname") + " " + rs.getString("lastname");
                            String appID = rs.getString("applicationID");
                %>
                    <option value="<%= email %>" <%= email.equals(selectedEmail) ? "selected" : "" %>>
                        ID: <%= appID %> — <%= fullName %> (<%= email %>)
                    </option>
                <%
                        }
                        if (!anyApproved) out.println("<p class='status-msg error'>No approved students found.</p>");
                    } catch (Exception e) {
                        out.println("<p class='status-msg error'>Error fetching students: " + e.getMessage() + "</p>");
                    }
                %>
            </select>
        </form>

        <% if (selectedEmail != null && !selectedEmail.trim().isEmpty()) {
            try (Connection con = DBUtil.getConnection()) {
                PreparedStatement ps = con.prepareStatement(
                    "SELECT applicationID, firstname, lastname, position1, position2, position3 FROM application_table WHERE emailid = ?");
                ps.setString(1, selectedEmail);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    String appID = rs.getString("applicationID");
                    String fullName = rs.getString("firstname") + " " + rs.getString("lastname");
        %>

        <!-- Interview scheduling form -->
        <form action="save_interview_schedule.jsp" method="post" class="application-form" id="interviewForm">
            <input type="hidden" name="studentEmail" value="<%= selectedEmail %>">
            <input type="hidden" name="applicationID" value="<%= appID %>">

            <p><strong>ID:</strong> <%= appID %></p>
            <p><strong>Name:</strong> <%= fullName %></p>

            <label><strong>Post:</strong></label>
            <select name="post" id="postSelect" class="input" required>
                <option value="">Select</option>
                <option value="<%= rs.getString("position1") %>"><%= rs.getString("position1") %></option>
                <option value="<%= rs.getString("position2") %>"><%= rs.getString("position2") %></option>
                <option value="<%= rs.getString("position3") %>"><%= rs.getString("position3") %></option>
            </select>

            <label><strong>Date:</strong></label>
            <input class="input" type="date" name="date" id="eventDate" required>

            <!-- Slots section -->
            <div id="slotsSection" style="display:none;">
                <label><strong>Time Slot 1:</strong></label>
                <select name="time1" id="slot1" class="input" required></select>

                <label><strong>Time Slot 2:</strong></label>
                <select name="time2" id="slot2" class="input" required></select>

                <label><strong>Time Slot 3:</strong></label>
                <select name="time3" id="slot3" class="input" required></select>

                <label><strong>Venue:</strong></label>
                <input type="text" name="venue" class="input" placeholder="e.g., Seminar Hall" required>

                <button type="submit" class="btn" style="margin-top:20px;">Confirm</button>
                <a href="admin_dashboard.jsp" class="btn danger" style="margin-left:10px;">Back</a>
            </div>
        </form>

        <script>
            // Disable past dates
            const today = new Date().toISOString().split("T")[0];
            document.getElementById("eventDate").setAttribute("min", today);

            const slotOptions = [
                "09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM", "11:00 AM",
                "11:30 AM", "12:00 PM", "12:30 PM", "01:00 PM", "01:30 PM",
                "02:00 PM", "02:30 PM", "03:00 PM", "03:30 PM", "04:00 PM"
            ];

            document.getElementById("eventDate").addEventListener("change", loadSlots);
            document.getElementById("postSelect").addEventListener("change", loadSlots);

            async function loadSlots() {
                const post = document.getElementById("postSelect").value;
                const date = document.getElementById("eventDate").value;

                if (!post || !date) return;

                const response = await fetch("taken_slots.jsp?post=" + encodeURIComponent(post) + "&date=" + encodeURIComponent(date));
                const taken = await response.json();

                const makeDropdown = (id) => {
                    const sel = document.getElementById(id);
                    sel.innerHTML = "";
                    slotOptions.forEach(time => {
                        const opt = document.createElement("option");
                        opt.value = time;
                        if (taken.includes(time)) {
                            opt.textContent = time + " (Taken)";
                            opt.disabled = true;
                            opt.className = "taken-slot";
                        } else {
                            opt.textContent = time;
                        }
                        sel.appendChild(opt);
                    });
                };

                makeDropdown("slot1");
                makeDropdown("slot2");
                makeDropdown("slot3");

                document.getElementById("slotsSection").style.display = "block";
                bindDuplicatePrevention();
            }

            // Disable same time in multiple slots dynamically
            function bindDuplicatePrevention() {
                const selects = ["slot1", "slot2", "slot3"].map(id => document.getElementById(id));

                function refreshOptions() {
                    const selectedTimes = new Set(selects.map(s => s.value).filter(v => v !== ""));
                    selects.forEach(sel => {
                        for (const opt of sel.options) {
                            if (selectedTimes.has(opt.value) && sel.value !== opt.value) {
                                opt.disabled = true;
                                opt.classList.add("taken-slot");
                            } else if (!opt.textContent.includes("(Taken)")) {
                                opt.disabled = false;
                                opt.classList.remove("taken-slot");
                            }
                        }
                    });
                }

                selects.forEach(sel => sel.addEventListener("change", refreshOptions));
            }
        </script>

        <% 
                } else {
                    out.println("<p class='status-msg error'>No record found for selected student.</p>");
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                out.println("<p class='status-msg error'>Error loading student details: " + e.getMessage() + "</p>");
            }
        } %>
    </div>
</div>
</body>
</html>
