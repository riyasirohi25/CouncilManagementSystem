<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, jakarta.servlet.http.*, java.text.SimpleDateFormat, java.util.Date" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userCategory") == null ||
        !"Admin".equalsIgnoreCase((String)userSession.getAttribute("userCategory"))) {
        response.sendRedirect("index.jsp");
        return;
    }

    String appID = request.getParameter("applicationID");
    String studentEmail = request.getParameter("studentEmail");
    String post = request.getParameter("post");
    String date = request.getParameter("date");
    String t1 = request.getParameter("time1");
    String t2 = request.getParameter("time2");
    String t3 = request.getParameter("time3");
    String venue = request.getParameter("venue");

    String message = "";

    // ✅ Helper to safely convert "9:30 AM" -> SQL Time
    java.util.function.Function<String, java.sql.Time> toSqlTime = (s) -> {
        if (s == null || s.trim().isEmpty()) return null;
        try {
            SimpleDateFormat in = new SimpleDateFormat("hh:mm a");
            in.setLenient(false);
            Date parsed = in.parse(s.trim());
            return new java.sql.Time(parsed.getTime());
        } catch (Exception ex) {
            return null;
        }
    };

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DBUtil.getConnection();

        // ✅ Fetch student's full name
        String fullName = "";
        PreparedStatement getName = con.prepareStatement("SELECT firstname, lastname FROM application_table WHERE applicationID = ?");
        getName.setInt(1, Integer.parseInt(appID));
        ResultSet rs = getName.executeQuery();
        if (rs.next()) {
            fullName = rs.getString("firstname") + " " + rs.getString("lastname");
        }
        rs.close();
        getName.close();

        java.sql.Time sqlT1 = toSqlTime.apply(t1);
        java.sql.Time sqlT2 = toSqlTime.apply(t2);
        java.sql.Time sqlT3 = toSqlTime.apply(t3);

        // ✅ 1️⃣ Check if same student slots are duplicated
        java.util.Set<String> uniqueSlots = new java.util.HashSet<>();
        if (sqlT1 != null) uniqueSlots.add(sqlT1.toString());
        if (sqlT2 != null) uniqueSlots.add(sqlT2.toString());
        if (sqlT3 != null) uniqueSlots.add(sqlT3.toString());

        if (uniqueSlots.size() < 3) {
            con.close();
            response.sendRedirect("schedule_interviews.jsp?msg=" + java.net.URLEncoder.encode("❌ Two or more selected slots are identical. Please choose distinct times.", "UTF-8"));
            return;
        }

        // ✅ 2️⃣ Check for overlap with already confirmed interviews
        PreparedStatement checkOverlap = con.prepareStatement(
            "SELECT confirmed_time FROM interview_table WHERE post = ? AND date = ? AND confirmed_time IS NOT NULL"
        );
        checkOverlap.setString(1, post);
        checkOverlap.setString(2, date);
        ResultSet overlapRs = checkOverlap.executeQuery();
        java.util.Set<String> bookedTimes = new java.util.HashSet<>();
        while (overlapRs.next()) {
            java.sql.Time booked = overlapRs.getTime("confirmed_time");
            if (booked != null) bookedTimes.add(booked.toString());
        }
        overlapRs.close();
        checkOverlap.close();

        boolean conflict = false;
        String conflictSlot = "";

        for (String booked : bookedTimes) {
            if (sqlT1 != null && booked.equals(sqlT1.toString())) { conflict = true; conflictSlot = t1; break; }
            if (sqlT2 != null && booked.equals(sqlT2.toString())) { conflict = true; conflictSlot = t2; break; }
            if (sqlT3 != null && booked.equals(sqlT3.toString())) { conflict = true; conflictSlot = t3; break; }
        }

        if (conflict) {
            con.close();
            response.sendRedirect("schedule_interviews.jsp?msg=" + java.net.URLEncoder.encode("❌ Cannot schedule. Slot " + conflictSlot + " is already booked by another student.", "UTF-8"));
            return;
        }

        // ✅ 3️⃣ Proceed with insert/update
        PreparedStatement check = con.prepareStatement("SELECT applicationID FROM interview_table WHERE applicationID = ?");
        check.setInt(1, Integer.parseInt(appID));
        ResultSet cr = check.executeQuery();

        if (cr.next()) {
            PreparedStatement ups = con.prepareStatement(
                "UPDATE interview_table SET name=?, post=?, date=?, time1=?, time2=?, time3=?, venue=? WHERE applicationID=?"
            );
            ups.setString(1, fullName);
            ups.setString(2, post);
            ups.setString(3, date);
            ups.setTime(4, sqlT1);
            ups.setTime(5, sqlT2);
            ups.setTime(6, sqlT3);
            ups.setString(7, venue);
            ups.setInt(8, Integer.parseInt(appID));
            ups.executeUpdate();
            ups.close();
        } else {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO interview_table (applicationID, name, post, date, time1, time2, time3, venue) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
            );
            ps.setInt(1, Integer.parseInt(appID));
            ps.setString(2, fullName);
            ps.setString(3, post);
            ps.setString(4, date);
            ps.setTime(5, sqlT1);
            ps.setTime(6, sqlT2);
            ps.setTime(7, sqlT3);
            ps.setString(8, venue);
            ps.executeUpdate();
            ps.close();
        }

        cr.close();
        check.close();
        con.close();

        message = "✅ Interview scheduled successfully for " + fullName + ".";
        response.sendRedirect("schedule_interviews.jsp?msg=" + java.net.URLEncoder.encode(message, "UTF-8"));

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p class='status-msg error'>Error scheduling interview: " + e.getMessage() + "</p>");
    }
%>
