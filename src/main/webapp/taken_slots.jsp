<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>

<%
    String post = request.getParameter("post");
    String date = request.getParameter("date");

    java.util.List<String> takenSlots = new java.util.ArrayList<>();
    java.text.SimpleDateFormat fmt = new java.text.SimpleDateFormat("hh:mm a");

    if (post != null && date != null && !post.isEmpty() && !date.isEmpty()) {
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT confirmed_time FROM interview_table WHERE post=? AND date=? AND confirmed_time IS NOT NULL")) {
            ps.setString(1, post);
            ps.setString(2, date);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Time t = rs.getTime("confirmed_time");
                if (t != null) takenSlots.add(fmt.format(t));
            }
            rs.close();
        } catch (Exception e) { }
    }

    out.print("[");
    for (int i = 0; i < takenSlots.size(); i++) {
        out.print("\"" + takenSlots.get(i) + "\"");
        if (i < takenSlots.size() - 1) out.print(",");
    }
    out.print("]");
%>
