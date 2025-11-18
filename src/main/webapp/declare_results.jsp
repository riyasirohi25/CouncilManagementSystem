<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*, jakarta.servlet.http.*" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userCategory") == null ||
        !"Admin".equalsIgnoreCase((String)userSession.getAttribute("userCategory"))) {
        response.sendRedirect("index.jsp");
        return;
    }

    String adminName = (String) userSession.getAttribute("userName");

    // Position capacities
    Map<String,Integer> capacity = new HashMap<>();
    capacity.put("Technology Coordinator", 2);
    capacity.put("Cultural Secretary", 2);
    capacity.put("Environment Secretary", 2);
    capacity.put("E-Sports Coordinator", 2);
    capacity.put("Editor Monochrome", 2);
    capacity.put("Editor Untitled", 2);
    capacity.put("Editor Aaina", 2);
    capacity.put("Vice Sports Captain Girls", 2);
    capacity.put("Vice Sports Captain Boys", 2);
    capacity.put("Vice Technology Coordinator", 2);
    capacity.put("Vice Cultural Secretary", 2);
    capacity.put("Deputy Editor Aaina", 2);

    // Position lists
    List<String> positions9 = Arrays.asList(
        "Vice Sports Captain Girls","Vice Sports Captain Boys",
        "Vice Fire House Captain","Vice Water House Captain",
        "Vice Earth House Captain","Vice Air House Captain",
        "Vice Technology Coordinator","Vice Cultural Secretary",
        "Vice Environment Secretary","Vice E-Sports Coordinator",
        "Deputy Editor Aaina"
    );

    List<String> positions11 = Arrays.asList(
        "President","Vice President",
        "Sports Captain Girls","Sports Captain Boys",
        "Fire House Captain","Water House Captain","Earth House Captain","Air House Captain",
        "Technology Coordinator","Cultural Secretary","Environment Secretary","E-Sports Coordinator",
        "Editor Monochrome","Editor Untitled","Editor Aaina"
    );

    String selClass = request.getParameter("class");
    String selPosition = request.getParameter("position");
    String selStudent = request.getParameter("studentEmail");

    String action = request.getMethod();
    String message = "", error = "";

    Map<String,Boolean> positionDisabled = new LinkedHashMap<>();
    List<Map<String,String>> candidates = new ArrayList<>();

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    boolean resultsDeclared = false;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DBUtil.getConnection();

        // Check official result status
        try {
            PreparedStatement pCheck = con.prepareStatement("SELECT isDeclared FROM result_status ORDER BY id DESC LIMIT 1");
            ResultSet rCheck = pCheck.executeQuery();
            if (rCheck.next()) {
                resultsDeclared = rCheck.getBoolean("isDeclared");
            }
            rCheck.close();
            pCheck.close();
        } catch (Exception ignored) {}

        // WHEN ADMIN CONFIRMS RESULT
        if ("POST".equalsIgnoreCase(action) &&
            selClass != null && selPosition != null &&
            selStudent != null && request.getParameter("result") != null) {

            String resultAction = request.getParameter("result");

            if (resultAction != null && !resultAction.trim().isEmpty()) {

                ps = con.prepareStatement(
                    "SELECT applicationID, firstname, lastname, class FROM application_table WHERE emailid = ?"
                );
                ps.setString(1, selStudent);
                rs = ps.executeQuery();

                if (rs.next()) {
                    int appID = rs.getInt("applicationID");
                    String name = rs.getString("firstname") + " " + rs.getString("lastname");
                    String curClass = rs.getString("class");

                    if (!selClass.equals(curClass)) {
                        error = "Class mismatch for selected student.";
                    } else {
                        int cap = capacity.getOrDefault(selPosition, 1);

                        ps.close();
                        ps = con.prepareStatement(
                            "SELECT COUNT(*) AS cnt FROM result_table r " +
                            "JOIN application_table a ON r.applicationID = a.applicationID " +
                            "WHERE a.class = ? AND r.post = ? AND r.resultStatus = 'Accepted'"
                        );
                        ps.setString(1, selClass);
                        ps.setString(2, selPosition);
                        ResultSet cr = ps.executeQuery();
                        int cnt = 0;
                        if (cr.next()) cnt = cr.getInt("cnt");
                        cr.close();

                        if ("Accepted".equalsIgnoreCase(resultAction) && cnt >= cap) {
                            error = "Capacity reached for '" + selPosition + "' in class " + selClass;
                        } else {
                            // INSERT or UPDATE result_table — FIXED VERSION
                            ps.close();
                            ps = con.prepareStatement(
                                "INSERT INTO result_table (applicationID, name, post, resultStatus) " +
                                "VALUES (?, ?, ?, ?) " +
                                "ON DUPLICATE KEY UPDATE post = VALUES(post), resultStatus = VALUES(resultStatus)"
                            );
                            ps.setInt(1, appID);
                            ps.setString(2, name);
                            ps.setString(3, selPosition);
                            ps.setString(4, resultAction);
                            ps.executeUpdate();

                            // ❌ REMOVED — notification column DOES NOT exist
                            // No more errors.

                            message = "Result declared: " + name + " → " + resultAction + " for " + selPosition;
                        }
                    }
                } else {
                    error = "Candidate not found.";
                }
            } else {
                error = "Please select a result (Accepted or Rejected).";
            }
        }

        // Disable positions if capacity full
        if (selClass != null) {
            List<String> posList = "9".equals(selClass) ? positions9 : positions11;

            for (String pos : posList) {
                int cap = capacity.getOrDefault(pos, 1);

                ps = con.prepareStatement(
                    "SELECT COUNT(*) AS cnt FROM result_table r " +
                    "JOIN application_table a ON r.applicationID = a.applicationID " +
                    "WHERE a.class = ? AND r.post = ? AND r.resultStatus='Accepted'"
                );
                ps.setString(1, selClass);
                ps.setString(2, pos);
                rs = ps.executeQuery();

                int count = 0;
                if (rs.next()) count = rs.getInt("cnt");

                positionDisabled.put(pos, count >= cap);

                rs.close();
                ps.close();
            }
        }

        // Fetch eligible candidates
        if (selClass != null && selPosition != null &&
            !selClass.isEmpty() && !selPosition.isEmpty()) {

            ps = con.prepareStatement(
                "SELECT a.applicationID, a.firstname, a.lastname, a.emailid, " +
                "a.position1, a.position2, a.position3 " +
                "FROM application_table a JOIN interview_table i " +
                "ON a.applicationID = i.applicationID " +
                "WHERE a.class = ? AND (a.position1 = ? OR a.position2 = ? OR a.position3 = ?) " +
                "ORDER BY a.firstname ASC"
            );

            ps.setString(1, selClass);
            ps.setString(2, selPosition);
            ps.setString(3, selPosition);
            ps.setString(4, selPosition);

            rs = ps.executeQuery();

            while (rs.next()) {
                Map<String,String> map = new HashMap<>();
                map.put("applicationID", String.valueOf(rs.getInt("applicationID")));
                map.put("firstname", rs.getString("firstname"));
                map.put("lastname", rs.getString("lastname"));
                map.put("emailid", rs.getString("emailid"));

                String pref = "";
                if (selPosition.equals(rs.getString("position1"))) pref = "Pref 1";
                else if (selPosition.equals(rs.getString("position2"))) pref = "Pref 2";
                else if (selPosition.equals(rs.getString("position3"))) pref = "Pref 3";

                map.put("preference", pref);
                candidates.add(map);
            }
        }

    } catch (Exception ex) {
        error = ex.getMessage();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignore) {}
        try { if (ps != null) ps.close(); } catch (Exception ignore) {}
        try { if (con != null) con.close(); } catch (Exception ignore) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Declare Results | Admin</title>
  <link rel="stylesheet" href="assets/style.css">
</head>
<body>
<div class="dashboard-bg">
  <div class="overlay"></div>

  <div class="dashboard-container">
    <div class="dashboard-header">
      <h1>Declare Results</h1>
      <p>Welcome, <strong><%= adminName %></strong></p>
    </div>

    <% if (!error.isEmpty()) { %>
      <p class="status-msg error"><%= error %></p>
    <% } else if (!message.isEmpty()) { %>
      <p class="status-msg success"><%= message %></p>
    <% } %>

    <!-- Toggle results -->
    <form method="post" action="toggle_result_status.jsp" style="margin-bottom:20px;">
        <button type="submit" class="btn">
            <%= resultsDeclared ? "Hide Declared Results" : "Declare Results Officially" %>
        </button>
    </form>

    <!-- Class & Position selection -->
    <form method="get" class="application-form">
      <label>Class</label>
      <select name="class" class="input" onchange="this.form.submit()">
        <option value="">Select Class</option>
        <option value="9" <%= "9".equals(selClass)?"selected":"" %>>Class 9</option>
        <option value="11" <%= "11".equals(selClass)?"selected":"" %>>Class 11</option>
      </select>

      <label>Position</label>
      <select name="position" class="input" onchange="this.form.submit()">
        <option value="">Select Position</option>
        <%
            List<String> posList = "9".equals(selClass) ? positions9 :
                                    ("11".equals(selClass) ? positions11 : new ArrayList<>());
            for (String pos : posList) {
                boolean disabled = positionDisabled.getOrDefault(pos, false);
        %>
          <option value="<%= pos %>"
                  <%= pos.equals(selPosition)?"selected":"" %>
                  <%= disabled ? "disabled" : "" %>>
            <%= pos %> <%= disabled?" (FULL)":"" %>
          </option>
        <% } %>
      </select>
    </form>

    <!-- Student selection + result -->
    <% if (selClass != null && selPosition != null && !selClass.isEmpty() && !selPosition.isEmpty()) { %>
    <form method="post" class="application-form">
      <input type="hidden" name="class" value="<%= selClass %>">
      <input type="hidden" name="position" value="<%= selPosition %>">

      <label>Select Student</label>
      <select name="studentEmail" class="input" onchange="this.form.submit()">
        <option value="">Select Student</option>
        <% for (Map<String,String> c : candidates) { %>
            <option value="<%= c.get("emailid") %>"
              <%= c.get("emailid").equals(selStudent)?"selected":"" %>>
              <%= c.get("firstname") %> <%= c.get("lastname") %>
              — <%= c.get("preference") %>
              (ID: <%= c.get("applicationID") %>)
            </option>
        <% } %>
      </select>

      <% if (selStudent != null && !selStudent.isEmpty()) {
            Map<String,String> selected = null;
            for (Map<String,String> c : candidates) {
                if (selStudent.equals(c.get("emailid"))) { selected = c; break; }
            }
            if (selected != null) { %>

            <p><strong>ID:</strong> <%= selected.get("applicationID") %></p>
            <p><strong>Post:</strong> <%= selPosition %></p>

            <label>Result</label>
            <select name="result" class="input" required>
              <option value="">Select Result</option>
              <option value="Accepted">Accepted</option>
              <option value="Rejected">Rejected</option>
            </select>

            <button type="submit" class="btn" style="margin-top:15px;">Confirm</button>

      <% }} %>
    </form>
    <% } %>

    <hr style="margin:30px 0;">
    <h2>Declared Results</h2>

    <table class="result-table">
      <tr><th>Class</th><th>Post</th><th>Name</th><th>Status</th></tr>

      <%
        try {
          Class.forName("com.mysql.cj.jdbc.Driver");
          con = DBUtil.getConnection();
          ps = con.prepareStatement(
            "SELECT a.class, r.post, r.name, r.resultStatus " +
            "FROM result_table r " +
            "JOIN application_table a ON r.applicationID = a.applicationID " +
            "ORDER BY a.class, r.post"
          );
          rs = ps.executeQuery();

          while (rs.next()) {
      %>
            <tr>
              <td><%= rs.getString("class") %></td>
              <td><%= rs.getString("post") %></td>
              <td><%= rs.getString("name") %></td>
              <td><%= rs.getString("resultStatus") %></td>
            </tr>
      <%  }
          rs.close();
          ps.close();
          con.close();
        } catch (Exception ex) {
          out.println("<tr><td colspan='4'>Error loading results: " + ex.getMessage() + "</td></tr>");
        }
      %>
    </table>

  </div>
</div>
</body>
</html>
