<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, jakarta.servlet.http.*, java.util.*" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>

<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userCategory") == null ||
        !"Student".equalsIgnoreCase((String)userSession.getAttribute("userCategory"))) {
        response.sendRedirect("index.jsp");
        return;
    }

    String email = (String) userSession.getAttribute("userEmail");
    String studentName = (String) userSession.getAttribute("userName");

    String message = "";
    String post = "";
    String result = "";
    String postClass = "";

    boolean resultsDeclared = false;
    boolean appearedForInterview = false;

    List<Map<String, String>> selectedList = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DBUtil.getConnection();

        // ✅ Ensure result_status table exists
        Statement st = con.createStatement();
        st.executeUpdate(
            "CREATE TABLE IF NOT EXISTS result_status (" +
            "id INT AUTO_INCREMENT PRIMARY KEY, " +
            "isDeclared BOOLEAN DEFAULT 0, " +
            "declareDate DATETIME)"
        );
        st.close();

        // ✅ Check if results are declared
        PreparedStatement psCheck = con.prepareStatement("SELECT isDeclared FROM result_status ORDER BY id DESC LIMIT 1");
        ResultSet rsCheck = psCheck.executeQuery();
        if (rsCheck.next()) resultsDeclared = rsCheck.getBoolean("isDeclared");
        rsCheck.close();
        psCheck.close();

        if (!resultsDeclared) {
            message = "⚠ Results have not been officially declared yet. Please check back later.";
        } else {
            // ✅ Check if student appeared for interview
            PreparedStatement psInterview = con.prepareStatement(
                "SELECT COUNT(*) AS cnt FROM interview_table i " +
                "JOIN application_table a ON i.applicationID = a.applicationID " +
                "WHERE a.emailid = ?"
            );
            psInterview.setString(1, email);
            ResultSet rsI = psInterview.executeQuery();
            if (rsI.next() && rsI.getInt("cnt") > 0) appearedForInterview = true;
            rsI.close();
            psInterview.close();

            // ✅ Fetch student’s result if available
            PreparedStatement ps = con.prepareStatement(
                "SELECT a.class, r.post, r.resultStatus " +
                "FROM result_table r " +
                "JOIN application_table a ON r.applicationID = a.applicationID " +
                "WHERE a.emailid = ?"
            );
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                postClass = rs.getString("class");
                post = rs.getString("post");
                result = rs.getString("resultStatus");
            }
            rs.close();
            ps.close();
            
            // ✅ Apply custom DSA Merge Sort to selected students list
            try {
                Class<?> sortUtilClass = Class.forName("utils.sortingUtil");
                java.lang.reflect.Method mergeSort = sortUtilClass.getMethod("mergeSort", List.class, Comparator.class);

                // Sort by class first, then by name (DSA)
                Comparator<Map<String, String>> comp = Comparator
                    .comparing((Map<String, String> m) -> m.get("class"))
                    .thenComparing(m -> m.get("name"));

                mergeSort.invoke(null, selectedList, comp);
            } catch (Exception e) {
                System.out.println("Sorting failed: " + e.getMessage());
            }


            // ✅ Personalized message logic
            if (!appearedForInterview) {
                message = "Sorry " + studentName + ", you were not shortlisted for the interview round. Keep trying — your effort matters!";
            } else if (result == null || result.isEmpty()) {
                message = "Your result is pending. Please wait for the final update.";
            } else if ("Accepted".equalsIgnoreCase(result)) {
                message = "🎉 Congratulations " + studentName + "! You have been selected for " + post + ".";
            } else if ("Rejected".equalsIgnoreCase(result)) {
                message = "❌ Sorry " + studentName + ", you were not selected for " + post + ". Keep up the good work!";
            }

            // ✅ Fetch all selected students for general list
            PreparedStatement psList = con.prepareStatement(
                "SELECT a.class, r.post, r.name " +
                "FROM result_table r " +
                "JOIN application_table a ON r.applicationID = a.applicationID " +
                "WHERE r.resultStatus = 'Accepted' " +
                "ORDER BY a.class, r.post"
            );
            ResultSet rsList = psList.executeQuery();
            while (rsList.next()) {
                Map<String, String> row = new HashMap<>();
                row.put("class", rsList.getString("class"));
                row.put("post", rsList.getString("post"));
                row.put("name", rsList.getString("name"));
                selectedList.add(row);
            }
            rsList.close();
            psList.close();
        }

        con.close();
    } catch (Exception e) {
        message = "Error loading result: " + e.getMessage();
    }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>View Result | Student Dashboard</title>
  <link rel="stylesheet" href="assets/style.css">
</head>
<body>
<div class="dashboard-bg">
  <div class="overlay"></div>
  <div class="dashboard-container">
    <div class="dashboard-header">
      <h1>My Result</h1>
      <p>Hello, <strong><%= studentName %></strong></p>
    </div>

    <% if (!resultsDeclared) { %>
      <p class="status-msg info"><%= message %></p>

    <% } else { %>
      <div class="application-form">
        <% if (post != null && !post.isEmpty()) { %>
          <p><strong>Class:</strong> <%= postClass %></p>
          <p><strong>Post:</strong> <%= post %></p>
          <p><strong>Result:</strong> 
            <span style="color:<%= "Accepted".equalsIgnoreCase(result) ? "#4CAF50" : "#E53935" %>;">
              <%= result %>
            </span>
          </p>
        <% } %>

        <div class="status-msg" style="margin-top:20px;">
          <%= message %>
        </div>
      </div>

      <% if (!selectedList.isEmpty()) { %>
        <hr class="divider">
        <h2>Students Selected</h2>
        <table class="result-table">
          <tr><th>Class</th><th>Post</th><th>Name</th></tr>
          <% for (Map<String,String> s : selectedList) { %>
            <tr>
              <td><%= s.get("class") %></td>
              <td><%= s.get("post") %></td>
              <td><%= s.get("name") %></td>
            </tr>
          <% } %>
        </table>
      <% } %>
    <% } %>

    <div class="back-btn-container">
      <a href="student_dashboard.jsp" class="btn">Back to Dashboard</a>
    </div>
  </div>
</div>
</body>
</html>
