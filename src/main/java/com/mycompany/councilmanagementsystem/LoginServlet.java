package com.mycompany.councilmanagementsystem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.regex.Pattern;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    private static final Pattern EMAIL_RE = Pattern.compile("^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$");
    Connection conn = null;
    Statement st = null;
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("emailid") != null ? request.getParameter("emailid").trim() : "";
        String password = request.getParameter("password") != null ? request.getParameter("password") : "";
        String category = request.getParameter("category") != null ? request.getParameter("category").trim() : "";

        boolean hasError = false;

        if (email.isEmpty()) {
            request.setAttribute("loginEmailErr", "Please enter your email.");
            hasError = true;
        } else if (!EMAIL_RE.matcher(email.toLowerCase()).matches()) {
            request.setAttribute("loginEmailErr", "Please enter a valid lowercase email.");
            hasError = true;
        }

        if (password.isEmpty()) {
            request.setAttribute("loginPasswordErr", "Please enter your password.");
            hasError = true;
        }

        if (category.isEmpty()) {
            request.setAttribute("loginCategoryErr", "Please select a category.");
            hasError = true;
        }

        if (hasError) {
            request.setAttribute("activeForm", "login");
            request.getRequestDispatcher("index.jsp").forward(request, response);
            return;
        }

        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DBConnection.getDBConnection();
            String sql = "SELECT firstname, lastname, password, category, isVerified FROM login_table WHERE emailid = ?";
            pst = conn.prepareStatement(sql);
            pst.setString(1, email);
            rs = pst.executeQuery();

            if (!rs.next()) {
                request.setAttribute("loginEmailErr", "No account found with this email.");
                request.setAttribute("activeForm", "login");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            String dbPassword = rs.getString("password");
            String dbCategory = rs.getString("category");
            boolean isVerified = rs.getBoolean("isVerified");
            String fullname = rs.getString("firstname") + " " + rs.getString("lastname");

            if (!category.equalsIgnoreCase(dbCategory)) {
                request.setAttribute("loginCategoryErr", "Selected category does not match this account.");
                request.setAttribute("activeForm", "login");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            if (!password.equals(dbPassword)) {
                request.setAttribute("loginPasswordErr", "Incorrect password.");
                request.setAttribute("activeForm", "login");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            if ( !isVerified) {
                request.setAttribute("loginGeneralErr", "Your account is not verified yet. Please wait for admin approval.");
                request.setAttribute("activeForm", "login");
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession();
            session.setAttribute("userEmail", email);
            session.setAttribute("userCategory", dbCategory);
            session.setAttribute("userName", fullname);
            session.setAttribute("userFirstName", rs.getString("firstname"));
            session.setAttribute("userLastName", rs.getString("lastname"));

            if ("Admin".equalsIgnoreCase(dbCategory)) {
                response.sendRedirect("admin_dashboard.jsp");
            } else {
                response.sendRedirect("student_dashboard.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("loginGeneralErr", "Internal server error. Please try again later.");
            request.setAttribute("activeForm", "login");
            request.getRequestDispatcher("index.jsp").forward(request, response);
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (pst != null) pst.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
}