package com.mycompany.councilmanagementsystem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.regex.Pattern;
import com.mycompany.councilmanagementsystem.DBUtil;

@WebServlet(name = "SignUpServlet", urlPatterns = {"/SignUpServlet"})
public class SignUpServlet extends HttpServlet {

    private static final Pattern EMAIL_RE = Pattern.compile("^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$");

    private boolean isPasswordStrong(String pw) {
        if (pw == null) return false;
        if (pw.length() < 8) return false;
        boolean hasDigit = pw.matches(".*\\d.*");
        boolean hasLetter = pw.matches(".*[A-Za-z].*");
        boolean hasSymbol = pw.matches(".*[^A-Za-z0-9].*");
        return hasDigit && hasLetter && hasSymbol;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String firstname = request.getParameter("firstname") != null ? request.getParameter("firstname").trim() : "";
        String lastname = request.getParameter("lastname") != null ? request.getParameter("lastname").trim() : "";
        String email = request.getParameter("emailid") != null ? request.getParameter("emailid").trim() : "";
        String password = request.getParameter("password") != null ? request.getParameter("password") : "";
        String category = request.getParameter("category") != null ? request.getParameter("category").trim() : "";

        boolean hasError = false;

        request.setAttribute("regFirst", firstname);
        request.setAttribute("regLast", lastname);
        request.setAttribute("regEmail", email);

        if (firstname.isEmpty() || lastname.isEmpty()) {
            request.setAttribute("registerGeneralErr", "First and last name are required.");
            hasError = true;
        }

        if (email.isEmpty()) {
            request.setAttribute("registerEmailErr", "Please enter your email.");
            hasError = true;
        } else if (!EMAIL_RE.matcher(email.toLowerCase()).matches()) {
            request.setAttribute("registerEmailErr", "Please enter a valid lowercase email (e.g. abc@domain.com).");
            hasError = true;
        }

        if (password.isEmpty()) {
            request.setAttribute("registerPasswordErr", "Please enter a password.");
            hasError = true;
        } else if (!isPasswordStrong(password)) {
            request.setAttribute("registerPasswordErr", "Password must be ≥8 chars and include letters, numbers & symbols.");
            hasError = true;
        }

        if (category.isEmpty()) {
            request.setAttribute("registerCategoryErr", "Please select a category.");
            hasError = true;
        } else if (!("Admin".equalsIgnoreCase(category) || "Student".equalsIgnoreCase(category))) {
            request.setAttribute("registerCategoryErr", "Invalid category.");
            hasError = true;
        }

        if (hasError) {
            request.setAttribute("activeForm", "register");
            request.getRequestDispatcher("index.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {

            // ✅ Check duplicate email in login_table
            try (PreparedStatement pst = conn.prepareStatement("SELECT emailid FROM login_table WHERE emailid = ?")) {
                pst.setString(1, email);
                ResultSet rs = pst.executeQuery();
                if (rs.next()) {
                    request.setAttribute("registerEmailErr", "An account with this email already exists.");
                    request.setAttribute("activeForm", "register");
                    request.getRequestDispatcher("index.jsp").forward(request, response);
                    return;
                }
            }

            // ✅ Insert new user
            String insertSql = "INSERT INTO login_table (firstname, lastname, emailid, password, category, isVerified) VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement pst = conn.prepareStatement(insertSql)) {
                pst.setString(1, firstname);
                pst.setString(2, lastname);
                pst.setString(3, email);
                pst.setString(4, password);
                pst.setString(5, category);
                pst.setBoolean(6, false);
                pst.executeUpdate();
            }

            // ✅ Ensure notifications table exists (with UNIQUE constraint)
            try (Statement st = conn.createStatement()) {
                st.executeUpdate(
                    "CREATE TABLE IF NOT EXISTS admin_notifications (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "message VARCHAR(255), " +
                    "email VARCHAR(100) UNIQUE, " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)"
                );
            }

            // ✅ Insert a single notification if not exists
            String noteMsg = firstname + " " + lastname + " (" + category + ") has registered and is awaiting verification.";
            try (PreparedStatement checkNotif = conn.prepareStatement("SELECT id FROM admin_notifications WHERE email = ?")) {
                checkNotif.setString(1, email);
                ResultSet notifRs = checkNotif.executeQuery();
                if (!notifRs.next()) {
                    try (PreparedStatement insNotif = conn.prepareStatement("INSERT INTO admin_notifications (message, email) VALUES (?, ?)")) {
                        insNotif.setString(1, noteMsg);
                        insNotif.setString(2, email);
                        insNotif.executeUpdate();
                    }
                }
                notifRs.close();
            } catch (SQLIntegrityConstraintViolationException dupEx) {
                // Duplicate notification ignored
            }

            request.setAttribute("registerSuccess", "Registration successful! Please wait for admin verification before login.");
            request.setAttribute("activeForm", "login");
            request.getRequestDispatcher("index.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("registerGeneralErr", "Internal server error: " + e.getMessage());
            request.setAttribute("activeForm", "register");
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }
}
