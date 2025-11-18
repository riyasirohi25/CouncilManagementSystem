<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.time.*, java.time.format.*, jakarta.servlet.http.*" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userCategory") == null ||
        !"Admin".equalsIgnoreCase((String) userSession.getAttribute("userCategory"))) {
        response.sendRedirect("index.jsp");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    boolean isDeclared = false;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DBUtil.getConnection();

        // ✅ Ensure table exists
        Statement st = con.createStatement();
        st.executeUpdate(
            "CREATE TABLE IF NOT EXISTS result_status (" +
            "id INT PRIMARY KEY, " +
            "isDeclared BOOLEAN DEFAULT 0, " +
            "declareDate DATETIME)"
        );
        st.close();

        // ✅ Ensure a single row exists (id = 1)
        ps = con.prepareStatement("INSERT IGNORE INTO result_status (id, isDeclared, declareDate) VALUES (1, 0, NOW())");
        ps.executeUpdate();
        ps.close();

        // ✅ Read current status
        ps = con.prepareStatement("SELECT isDeclared FROM result_status WHERE id = 1");
        rs = ps.executeQuery();
        if (rs.next()) {
            isDeclared = rs.getBoolean("isDeclared");
        }
        rs.close();
        ps.close();

        // ✅ Toggle status (update same row instead of inserting new)
        boolean newStatus = !isDeclared;
        ps = con.prepareStatement("UPDATE result_status SET isDeclared = ?, declareDate = NOW() WHERE id = 1");
        ps.setBoolean(1, newStatus);
        ps.executeUpdate();
        ps.close();

        // ✅ Set a session message
        String msg = newStatus
            ? "Results have been officially declared!"
            : "Results are now hidden from students.";
        userSession.setAttribute("toggleMessage", msg);

    } catch (Exception e) {
        userSession.setAttribute("toggleMessage", "Error toggling result status: " + e.getMessage());
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignore) {}
        try { if (ps != null) ps.close(); } catch (Exception ignore) {}
        try { if (con != null) con.close(); } catch (Exception ignore) {}
    }

    // ✅ Redirect back
    response.sendRedirect("declare_results.jsp");
%>
