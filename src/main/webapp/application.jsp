<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.time.*, jakarta.servlet.http.*, jakarta.servlet.*" %>
<%@ page import="com.mycompany.councilmanagementsystem.DBUtil" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userCategory") == null || !"Student".equalsIgnoreCase((String)sess.getAttribute("userCategory"))) {
        response.sendRedirect("index.jsp");
        return;
    }

    String email = (String) sess.getAttribute("userEmail");
    String firstName = "";
    String lastName = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DBUtil.getConnection();
        PreparedStatement ps = con.prepareStatement("SELECT firstname, lastname FROM login_table WHERE emailid = ?");
        ps.setString(1, email);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            firstName = rs.getString("firstname");
            lastName = rs.getString("lastname");
        }
        con.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

    String statusMsg = "";
    String errorMsg = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String gender = request.getParameter("gender");
        String className = request.getParameter("class");
        String house = request.getParameter("house");
        String pos1 = request.getParameter("position1");
        String pos2 = request.getParameter("position2");
        String pos3 = request.getParameter("position3");
        String achievements = request.getParameter("achievements");
        String reflection = request.getParameter("reflection");

        if (gender == null || gender.isEmpty() ||
            className == null || className.isEmpty() ||
            house == null || house.isEmpty() ||
            pos1 == null || pos2 == null || pos3 == null ||
            achievements == null || achievements.trim().isEmpty() ||
            reflection == null || reflection.trim().isEmpty()) {
            errorMsg = "Please fill all fields correctly before submitting.";
        } else {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DBUtil.getConnection();

                PreparedStatement check = con.prepareStatement("SELECT * FROM application_table WHERE emailid=?");
                check.setString(1, email);
                ResultSet rs = check.executeQuery();
                if (rs.next()) {
                    errorMsg = "You have already submitted an application.";
                } else {
                    String combined = (pos1 + pos2 + pos3).toLowerCase();
                    String electionType = "Student";
                    if (combined.contains("technology") || combined.contains("cultural") ||
                        combined.contains("environment") || combined.contains("e-sports") ||
                        combined.contains("editor")) {
                        electionType = "Teacher";
                    }

                    PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO application_table (firstname, lastname, gender, house, emailid, class, position1, position2, position3, achievement, reflection, status, session, dateSubmission, timeSubmission, electionType) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                    );
                    ps.setString(1, firstName);
                    ps.setString(2, lastName);
                    ps.setString(3, gender);
                    ps.setString(4, house);
                    ps.setString(5, email);
                    ps.setString(6, className);
                    ps.setString(7, pos1);
                    ps.setString(8, pos2);
                    ps.setString(9, pos3);
                    ps.setString(10, achievements);
                    ps.setString(11, reflection);
                    ps.setString(12, "Pending");
                    ps.setString(13, sess.getId());
                    ps.setDate(14, java.sql.Date.valueOf(LocalDate.now()));
                    ps.setTime(15, java.sql.Time.valueOf(LocalTime.now()));
                    ps.setString(16, electionType);

                    ps.executeUpdate();
                    ps.close();
                    statusMsg = "Application submitted successfully! You can check your status in the dashboard.";
                }
                con.close();
            } catch (Exception e) {
                errorMsg = "Error: " + e.getMessage();
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Student Council Application Form</title>
    <link rel="stylesheet" href="assets/style.css">
</head>
<body>
<div class="dashboard-bg">
  <div class="overlay"></div>
  <div class="dashboard-container">
    <div class="dashboard-header">
      <h1>Student Council Application Form</h1>
      <p>Fill in all the required fields carefully and submit your application.</p>
    </div>

    <% if (!errorMsg.isEmpty()) { %>
      <p class="status-msg error"><%= errorMsg %></p>
    <% } else if (!statusMsg.isEmpty()) { %>
      <p class="status-msg success"><%= statusMsg %></p>
    <% } %>

    <form class="application-form" method="POST" action="">
      <div class="two-col">
        <div class="field">
          <label>First Name</label>
          <input type="text" name="firstName" class="input" value="<%= firstName %>" readonly>
        </div>
        <div class="field">
          <label>Last Name</label>
          <input type="text" name="lastName" class="input" value="<%= lastName %>" readonly>
        </div>
      </div>

      <div class="field">
        <label>Email</label>
        <input type="email" name="email" class="input" value="<%= email %>" readonly>
      </div>

      <div class="three-col">
        <div class="field">
          <label>Gender</label>
          <select name="gender" class="input" required>
            <option value="">Select Gender</option>
            <option value="Male">Male</option>
            <option value="Female">Female</option>
            <option value="Other">Other</option>
          </select>
        </div>
        <div class="field">
          <label>Class</label>
          <select name="class" class="input" id="classSelect" required>
            <option value="">Select Class</option>
            <option value="9">Class 9</option>
            <option value="11">Class 11</option>
          </select>
        </div>
        <div class="field">
          <label>House</label>
          <select name="house" class="input" id="houseSelect" required>
            <option value="">Select House</option>
            <option value="Fire House">Fire House</option>
            <option value="Water House">Water House</option>
            <option value="Earth House">Earth House</option>
            <option value="Air House">Air House</option>
          </select>
        </div>
      </div>

      <div class="three-col">
        <div class="field">
          <label>Preferred Position 1</label>
          <select name="position1" class="input" id="position1" required></select>
        </div>
        <div class="field">
          <label>Preferred Position 2</label>
          <select name="position2" class="input" id="position2" required></select>
        </div>
        <div class="field">
          <label>Preferred Position 3</label>
          <select name="position3" class="input" id="position3" required></select>
        </div>
      </div>

      <div class="field">
        <label>Achievements (max 200 words)</label>
        <textarea name="achievements" maxlength="1200" placeholder="Mention your key achievements..." class="input" required></textarea>
      </div>

      <div class="field">
        <label>Reflection (max 500 words)</label>
        <textarea name="reflection" maxlength="3000" placeholder="Write your reflection on leadership and contribution..." class="input" required></textarea>
      </div>

      <button class="btn" type="submit">Submit Application</button>
      <div class="back-btn-container">
        <a href="student_dashboard.jsp" class="btn">Back to Dashboard</a>
      </div>
    </form>
  </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', () => {
  const classSelect = document.getElementById('classSelect');
  const houseSelect = document.getElementById('houseSelect');
  const pos1 = document.getElementById('position1');
  const pos2 = document.getElementById('position2');
  const pos3 = document.getElementById('position3');
  const dropdowns = [pos1, pos2, pos3];

  const positions9 = [
    "Vice Sports Captain Girls","Vice Sports Captain Boys",
    "Vice Fire House Captain","Vice Water House Captain","Vice Earth House Captain","Vice Air House Captain",
    "Vice Technology Coordinator","Vice Cultural Secretary","Vice Environment Secretary","Vice E-Sports Coordinator","Deputy Editor Aaina"
  ];

  const positions11 = [
    "President","Vice President",
    "Sports Captain Girls","Sports Captain Boys",
    "Fire House Captain","Water House Captain","Earth House Captain","Air House Captain",
    "Technology Coordinator","Cultural Secretary","Environment Secretary","E-Sports Coordinator",
    "Editor Monochrome","Editor Untitled","Editor Aaina"
  ];

  function populatePositions() {
    const cls = classSelect.value;
    const house = houseSelect.value;
    if (!cls) return;

    const list = cls === "9" ? positions9 : positions11;

    dropdowns.forEach(d => {
      d.innerHTML = '<option value="">Select Position</option>';
      list.forEach(p => {
        if (house && p.includes("House") && !p.includes(house.split(" ")[0])) return;
        const opt = document.createElement("option");
        opt.value = p;
        opt.textContent = p;
        d.appendChild(opt);
      });
    });
  }

  function enforceUniqueSelections() {
    const selected = dropdowns.map(d => d.value).filter(v => v);
    dropdowns.forEach(d => {
      Array.from(d.options).forEach(opt => {
        opt.disabled = selected.includes(opt.value) && d.value !== opt.value;
      });
    });
  }

  classSelect.addEventListener("change", populatePositions);
  houseSelect.addEventListener("change", populatePositions);
  dropdowns.forEach(d => d.addEventListener("change", enforceUniqueSelections));
});
</script>
</body>
</html>
