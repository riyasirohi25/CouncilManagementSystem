<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.time.*, java.time.temporal.ChronoUnit, jakarta.servlet.http.*" %>
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
    String gender = "";
    String house = "";
    String className = "";
    String pos1 = "";
    String pos2 = "";
    String pos3 = "";
    String achievements = "";
    String reflection = "";
    String errorMsg = "";
    String successMsg = "";
    boolean canEdit = false;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DBUtil.getConnection();

        // Fetch application details
        PreparedStatement ps = con.prepareStatement("SELECT * FROM application_table WHERE emailid = ?");
        ps.setString(1, email);
        ResultSet rs = ps.executeQuery();

        Timestamp firstSubmission = null;

        if (rs.next()) {
            firstName = rs.getString("firstname");
            lastName = rs.getString("lastname");
            gender = rs.getString("gender") != null ? rs.getString("gender") : "";
            house = rs.getString("house");
            className = rs.getString("class");
            pos1 = rs.getString("position1");
            pos2 = rs.getString("position2");
            pos3 = rs.getString("position3");
            achievements = rs.getString("achievement");
            reflection = rs.getString("reflection");

            firstSubmission = Timestamp.valueOf(rs.getDate("dateSubmission").toLocalDate()
                    .atTime(rs.getTime("timeSubmission").toLocalTime()));
        }

        if (firstSubmission != null) {
            LocalDateTime firstTime = firstSubmission.toLocalDateTime();
            LocalDateTime now = LocalDateTime.now();
            long minutesPassed = ChronoUnit.MINUTES.between(firstTime, now);
            canEdit = minutesPassed < (24L * 60L);
        } else {
            errorMsg = "No application record found.";
        }

        con.close();
    } catch (Exception e) {
        errorMsg = "Error fetching application: " + e.getMessage();
    }

    // --- Handle Update ---
    if ("POST".equalsIgnoreCase(request.getMethod()) && canEdit) {
        String newGender = request.getParameter("gender");
        String newHouse = request.getParameter("house");
        String newClass = request.getParameter("class");
        String newPos1 = request.getParameter("position1");
        String newPos2 = request.getParameter("position2");
        String newPos3 = request.getParameter("position3");
        String newAchievements = request.getParameter("achievements");
        String newReflection = request.getParameter("reflection");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DBUtil.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "UPDATE application_table SET gender=?, house=?, class=?, position1=?, position2=?, position3=?, achievement=?, reflection=? WHERE emailid=?"
            );
            ps.setString(1, newGender);
            ps.setString(2, newHouse);
            ps.setString(3, newClass);
            ps.setString(4, newPos1);
            ps.setString(5, newPos2);
            ps.setString(6, newPos3);
            ps.setString(7, newAchievements);
            ps.setString(8, newReflection);
            ps.setString(9, email);
            ps.executeUpdate();

            ps.close();
            con.close();
            successMsg = "Application updated successfully!";
        } catch (Exception e) {
            errorMsg = "Error updating application: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Edit Application</title>
    <link rel="stylesheet" href="assets/style.css">
</head>
<body>
<div class="dashboard-bg">
  <div class="overlay"></div>

  <div class="dashboard-container">
    <div class="dashboard-header">
      <h1>Edit Your Application</h1>
      <p>You may edit your application only within 24 hours of submission.</p>
    </div>

    <% if (!errorMsg.isEmpty()) { %>
      <p class="status-msg error"><%= errorMsg %></p>
    <% } else if (!successMsg.isEmpty()) { %>
      <p class="status-msg success"><%= successMsg %></p>
    <% } %>

    <% if (!canEdit && errorMsg.isEmpty()) { %>
      <p class="status-msg error">⏳ Editing locked — 24 hours have passed since your first submission.</p>
    <% } %>

    <% if (canEdit) { %>
    <form class="application-form" method="POST" action="">
      <div class="two-col">
        <div class="field">
          <label>First Name</label>
          <input type="text" value="<%= firstName %>" readonly>
        </div>
        <div class="field">
          <label>Last Name</label>
          <input type="text" value="<%= lastName %>" readonly>
        </div>
      </div>

      <div class="three-col">
        <div class="field">
          <label>Email</label>
          <input type="email" value="<%= email %>" readonly>
        </div>
        <div class="field">
          <label>Gender</label>
          <select name="gender" class="input" required>
            <option value="">Select Gender</option>
            <option value="Male" <%= "Male".equals(gender)?"selected":"" %>>Male</option>
            <option value="Female" <%= "Female".equals(gender)?"selected":"" %>>Female</option>
            <option value="Other" <%= "Other".equals(gender)?"selected":"" %>>Other</option>
          </select>
        </div>
        <div class="field">
          <label>Class</label>
          <select name="class" id="classSelect" class="input" required>
            <option value="">Select Class</option>
            <option value="9" <%= "9".equals(className)?"selected":"" %>>Class 9</option>
            <option value="11" <%= "11".equals(className)?"selected":"" %>>Class 11</option>
          </select>
        </div>
      </div>

      <div class="three-col">
        <div class="field">
          <label>House</label>
          <select name="house" id="houseSelect" class="input" required>
            <option value="">Select House</option>
            <option value="Fire House" <%= "Fire House".equals(house)?"selected":"" %>>Fire House</option>
            <option value="Water House" <%= "Water House".equals(house)?"selected":"" %>>Water House</option>
            <option value="Earth House" <%= "Earth House".equals(house)?"selected":"" %>>Earth House</option>
            <option value="Air House" <%= "Air House".equals(house)?"selected":"" %>>Air House</option>
          </select>
        </div>
        <div class="field">
          <label>Preferred Position 1</label>
          <select name="position1" class="input" id="position1" required>
            <option value="<%= pos1 %>"><%= pos1 %></option>
          </select>
        </div>
        <div class="field">
          <label>Preferred Position 2</label>
          <select name="position2" class="input" id="position2" required>
            <option value="<%= pos2 %>"><%= pos2 %></option>
          </select>
        </div>
      </div>

      <div class="three-col">
        <div class="field">
          <label>Preferred Position 3</label>
          <select name="position3" class="input" id="position3" required>
            <option value="<%= pos3 %>"><%= pos3 %></option>
          </select>
        </div>
      </div>

      <div class="field">
        <label>Achievements (max 200 words)</label>
        <textarea name="achievements" maxlength="1200" required><%= achievements %></textarea>
      </div>

      <div class="field">
        <label>Reflection (max 500 words)</label>
        <textarea name="reflection" maxlength="3000" required><%= reflection %></textarea>
      </div>

      <button class="btn" type="submit">Update Application</button>
      <div class="back-btn-container" style="margin-top:15px;">
        <a href="student_dashboard.jsp" class="btn">Back to Dashboard</a>
      </div>
    </form>
    <% } %>
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
      const currentValue = d.value;
      d.innerHTML = '<option value="">Select Position</option>';
      list.forEach(p => {
        if (
          (house.includes("Fire") && p.includes("Water")) ||
          (house.includes("Fire") && p.includes("Earth")) ||
          (house.includes("Fire") && p.includes("Air")) ||
          (house.includes("Water") && p.includes("Fire")) ||
          (house.includes("Water") && p.includes("Earth")) ||
          (house.includes("Water") && p.includes("Air")) ||
          (house.includes("Earth") && p.includes("Fire")) ||
          (house.includes("Earth") && p.includes("Water")) ||
          (house.includes("Earth") && p.includes("Air")) ||
          (house.includes("Air") && p.includes("Fire")) ||
          (house.includes("Air") && p.includes("Water")) ||
          (house.includes("Air") && p.includes("Earth"))
        ) return;

        const opt = document.createElement("option");
        opt.value = p;
        opt.textContent = p;
        if (p === currentValue) opt.selected = true;
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

  populatePositions();
  enforceUniqueSelections();
});
</script>
</body>
</html>
