package com.mycompany.councilmanagementsystem;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.ServletException;
import java.io.IOException;
import java.sql.*;

@WebServlet(name="ChangePasswordServlet", urlPatterns={"/ChangePasswordServlet"})
public class ChangePasswordServlet extends HttpServlet {

    private static final String PW_REGEX = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*]).{8,20}$";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userEmail") == null) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        String email = (String) s.getAttribute("userEmail");
        String current = req.getParameter("currentPassword");
        String newPw = req.getParameter("newPassword");
        String confirmPw = req.getParameter("confirmPassword");

        // ---------------------------
        // 1️⃣ Check new password empty
        // ---------------------------
        if (newPw == null || confirmPw == null || newPw.trim().isEmpty() || confirmPw.trim().isEmpty()) {
            redirectError(resp, req, "New password fields cannot be empty");
            return;
        }

        // ---------------------------
        // 2️⃣ Check password strength
        // ---------------------------
        if (!newPw.matches(PW_REGEX)) {
            redirectError(resp, req,
                "Password must include letters, a number & a special character (8–20 chars)");
            return;
        }

        // ---------------------------
        // 3️⃣ Check new == confirm
        // ---------------------------
        if (!newPw.equals(confirmPw)) {
            redirectError(resp, req, "New passwords do not match");
            return;
        }

        // ---------------------------
        // 4️⃣ Validate current password
        // ---------------------------
        String storedPw = "";

        try (Connection c = DBUtil.getConnection();
             PreparedStatement p = c.prepareStatement("SELECT password FROM login_table WHERE emailid=?")) {

            p.setString(1, email);
            ResultSet r = p.executeQuery();

            if (r.next()) {
                storedPw = r.getString("password");
            } else {
                redirectError(resp, req, "User not found");
                return;
            }

        } catch (Exception ex) {
            redirectError(resp, req, "Error verifying current password: " + ex.getMessage());
            return;
        }

        if (!storedPw.equals(current)) {
            redirectError(resp, req, "Current password is incorrect");
            return;
        }

        // ---------------------------
        // 5️⃣ Update password
        // ---------------------------
        try (Connection c = DBUtil.getConnection();
             PreparedStatement up = c.prepareStatement(
                     "UPDATE login_table SET password=? WHERE emailid=?")) {

            up.setString(1, newPw);
            up.setString(2, email);
            up.executeUpdate();

        } catch (Exception ex) {
            redirectError(resp, req, "Error updating password: " + ex.getMessage());
            return;
        }

        // Success
        resp.sendRedirect(req.getContextPath() + "/ManageProfile.jsp?msg=" +
                java.net.URLEncoder.encode("Password updated successfully", "UTF-8"));
    }

    private void redirectError(HttpServletResponse resp, HttpServletRequest req, String msg) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/ManageProfile.jsp?errorMsg=" +
                java.net.URLEncoder.encode(msg, "UTF-8"));
    }
}
