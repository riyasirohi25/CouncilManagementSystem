package com.mycompany.councilmanagementsystem;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.ServletException;
import java.io.IOException;
import java.sql.*;

@WebServlet(name = "ResetSystemServlet", urlPatterns = {"/ResetSystemServlet"})
public class ResetSystemServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession sess = req.getSession(false);
        if (sess == null || sess.getAttribute("userCategory") == null ||
            !"Admin".equalsIgnoreCase((String) sess.getAttribute("userCategory"))) {
            resp.sendRedirect("index.jsp");
            return;
        }

        try (Connection con = DBUtil.getConnection();
             Statement st = con.createStatement()) {

            // disable foreign key constraints first
            st.execute("SET FOREIGN_KEY_CHECKS = 0");

            // TRUNCATE all council-related tables
            st.executeUpdate("TRUNCATE TABLE application_table");
            st.executeUpdate("TRUNCATE TABLE interview_table");

            // Your missing result table
            try { st.executeUpdate("TRUNCATE TABLE result_table"); } catch (Exception ignored) {}

            // Optional tables
            try { st.executeUpdate("TRUNCATE TABLE council_events"); } catch (Exception ignored) {}
            try { st.executeUpdate("TRUNCATE TABLE council_members"); } catch (Exception ignored) {}
            try { st.executeUpdate("TRUNCATE TABLE admin_notifications"); } catch (Exception ignored) {}

            // Re-enable FK checks
            st.execute("SET FOREIGN_KEY_CHECKS = 1");

            resp.sendRedirect("reset_system.jsp?msg=" +
                    java.net.URLEncoder.encode("System reset completed successfully!", "UTF-8"));

        } catch (Exception ex) {
            resp.sendRedirect("reset_system.jsp?error=" +
                    java.net.URLEncoder.encode("Reset failed: " + ex.getMessage(), "UTF-8"));
        }
    }
}
