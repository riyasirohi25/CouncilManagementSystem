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

    String studentEmail = request.getParameter("studentEmail");
    String action = request.getParameter("action");
    String message = "";

    if (studentEmail == null || action == null || studentEmail.trim().isEmpty()) {
        response.sendRedirect("admin_view_application.jsp?msg=Invalid+Request");
        return;
    }

    String statusUpdate = "";
    if ("reject".equalsIgnoreCase(action)) {
        statusUpdate = "Rejected";
    } else if ("shortlist".equalsIgnoreCase(action)) {
        statusUpdate = "Approved"; // ✅ enum-compatible
    } else {
        response.sendRedirect("admin_view_application.jsp?msg=Invalid+Action");
        return;
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DBUtil.getConnection();

        PreparedStatement ps = con.prepareStatement(
            "UPDATE application_table SET status = ? WHERE emailid = ?"
        );
        ps.setString(1, statusUpdate);
        ps.setString(2, studentEmail);

        int updated = ps.executeUpdate();
        if (updated > 0) {
            message = "Application status updated to " + statusUpdate + ".";
        } else {
            message = "No record found for the selected student.";
        }

        ps.close();
        con.close();
    } catch (Exception e) {
        message = "Error updating status: " + e.getMessage();
    }

    response.sendRedirect("admin_view_application.jsp?msg=" + java.net.URLEncoder.encode(message, "UTF-8"));
%>
