<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, jakarta.servlet.http.*, java.text.SimpleDateFormat, java.util.Date" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userCategory") == null ||
        !"Student".equalsIgnoreCase((String)userSession.getAttribute("userCategory"))) {
        response.sendRedirect("index.jsp");
        return;
    }

    String message = "";

    try {
        String appIDParam = request.getParameter("applicationID");
        String selectedSlot = request.getParameter("selectedSlot");

        if (appIDParam == null || selectedSlot == null || selectedSlot.trim().isEmpty()) {
            response.sendRedirect("interview_schedule.jsp?msg=" + java.net.URLEncoder.encode("Invalid slot selection.", "UTF-8"));
            return;
        }

        int appID = Integer.parseInt(appIDParam);

        // ✅ Convert "9:30 AM" → SQL Time
        java.sql.Time sqlTime = null;
        try {
            SimpleDateFormat inFormat = new SimpleDateFormat("hh:mm a");
            inFormat.setLenient(false);
            Date parsedTime = inFormat.parse(selectedSlot.trim());
            sqlTime = new java.sql.Time(parsedTime.getTime());
        } catch (Exception parseEx) {
            response.sendRedirect("interview_schedule.jsp?msg=" + java.net.URLEncoder.encode("Invalid time format selected.", "UTF-8"));
            return;
        }

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DBUtil.getConnection();

        // ✅ Check if slot is already taken (same post, same date, same time)
        PreparedStatement check = con.prepareStatement(
            "SELECT COUNT(*) FROM interview_table WHERE confirmed_time = ? " +
            "AND date = (SELECT date FROM interview_table WHERE applicationID = ?) " +
            "AND post = (SELECT post FROM interview_table WHERE applicationID = ?)"
        );
        check.setTime(1, sqlTime);
        check.setInt(2, appID);
        check.setInt(3, appID);
        ResultSet chk = check.executeQuery();
        chk.next();
        int count = chk.getInt(1);
        chk.close();
        check.close();

        if (count > 0) {
            response.sendRedirect("interview_schedule.jsp?msg=" + 
                java.net.URLEncoder.encode("This slot has already been taken. Please select another time.", "UTF-8"));
            con.close();
            return;
        }

        // ✅ Update confirmed time
        PreparedStatement ps = con.prepareStatement(
            "UPDATE interview_table SET confirmed_time = ? WHERE applicationID = ?"
        );
        ps.setTime(1, sqlTime);
        ps.setInt(2, appID);
        int updated = ps.executeUpdate();
        ps.close();
        con.close();

        if (updated > 0)
            message = "Your interview slot has been confirmed successfully!";
        else
            message = "Unable to confirm slot. Please try again.";

        response.sendRedirect("interview_schedule.jsp?msg=" + java.net.URLEncoder.encode(message, "UTF-8"));

    } catch (Exception e) {
        out.println("<p class='status-msg error'>Error updating slot: " + e.getMessage() + "</p>");
    }
%>
