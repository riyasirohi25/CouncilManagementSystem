<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // determine active form (login/register)
    String activeForm = (String) request.getAttribute("activeForm");
    if (activeForm == null) activeForm = "login";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>Student Council Portal</title>
  <link rel="stylesheet" href="assets/style.css"/>
</head>
<body>
  <div class="bg"></div>
  <div class="overlay"></div>

  <div class="wrap">
    <div class="card">
      <div class="visual">
        <div class="logo">Student Council Portal</div>
        <div class="subtitle">
          Leadership • Innovation • Community<br>
          Apply for council positions, attend interviews, and build campus impact.
        </div>
      </div>

      <div class="form-wrap">
        <div class="tabs">
          <div id="tabLogin" class="tab">Login</div>
          <div id="tabRegister" class="tab">Register</div>
        </div>

        <div class="form-card">
          <div class="forms-container">
            <!-- LOGIN PANEL -->
            <div id="panelLogin" class="form-panel">
              <form id="loginForm" action="LoginServlet" method="post" novalidate>
                <div class="field">
                  <input class="input" type="email" name="emailid" id="loginEmail" placeholder="Email ID" autocomplete="off">
                  <div class="error-msg <%= (request.getAttribute("loginEmailErr")!=null) ? "visible-msg" : "" %>">
                    <%= request.getAttribute("loginEmailErr") != null ? request.getAttribute("loginEmailErr") : "" %>
                  </div>
                </div>

                <div class="field">
                  <input class="input" type="password" name="password" id="loginPassword" placeholder="Password" autocomplete="new-password">
                  <div class="error-msg <%= (request.getAttribute("loginPasswordErr")!=null) ? "visible-msg" : "" %>">
                    <%= request.getAttribute("loginPasswordErr") != null ? request.getAttribute("loginPasswordErr") : "" %>
                  </div>
                </div>

                <div class="field">
                  <select class="input" name="category" id="loginCategory">
                    <option value="">Select Category</option>
                    <option value="Admin">Admin</option>
                    <option value="Student">Student</option>
                  </select>
                  <div class="error-msg <%= (request.getAttribute("loginCategoryErr")!=null) ? "visible-msg" : "" %>">
                    <%= request.getAttribute("loginCategoryErr") != null ? request.getAttribute("loginCategoryErr") : "" %>
                  </div>
                </div>

                <div class="error-msg <%= (request.getAttribute("loginGeneralErr")!=null) ? "visible-msg" : "" %>">
                  <%= request.getAttribute("loginGeneralErr") != null ? request.getAttribute("loginGeneralErr") : "" %>
                </div>

                <button class="btn" type="submit">Login</button>
              </form>
            </div>

            <!-- REGISTER PANEL -->
            <div id="panelRegister" class="form-panel">
              <form id="registerForm" action="SignUpServlet" method="post" novalidate>
                <!-- first & last name directly at top (no big gap) -->
                <div class="field">
                  <input class="input" type="text" name="firstname" id="firstname" placeholder="First Name" value="<%= request.getAttribute("regFirst")!=null ? request.getAttribute("regFirst") : "" %>">
                </div>

                <div class="field">
                  <input class="input" type="text" name="lastname" id="lastname" placeholder="Last Name" value="<%= request.getAttribute("regLast")!=null ? request.getAttribute("regLast") : "" %>">
                </div>

                <div class="field">
                  <input class="input" type="email" name="emailid" id="regEmail" placeholder="Email ID" value="<%= request.getAttribute("regEmail")!=null ? request.getAttribute("regEmail") : "" %>">
                  <div class="error-msg <%= (request.getAttribute("registerEmailErr")!=null) ? "visible-msg" : "" %>">
                    <%= request.getAttribute("registerEmailErr") != null ? request.getAttribute("registerEmailErr") : "" %>
                  </div>
                </div>

                <div class="field">
                  <input class="input" type="password" name="password" id="regPassword" placeholder="Password" autocomplete="new-password">
                  <div class="error-msg <%= (request.getAttribute("registerPasswordErr")!=null) ? "visible-msg" : "" %>">
                    <%= request.getAttribute("registerPasswordErr") != null ? request.getAttribute("registerPasswordErr") : "" %>
                  </div>
                </div>

                <div class="field">
                  <select class="input" name="category" id="regCategory">
                    <option value="">Select Category</option>
                    <option value="Admin">Admin</option>
                    <option value="Student">Student</option>
                  </select>
                  <div class="error-msg <%= (request.getAttribute("registerCategoryErr")!=null) ? "visible-msg" : "" %>">
                    <%= request.getAttribute("registerCategoryErr") != null ? request.getAttribute("registerCategoryErr") : "" %>
                  </div>
                </div>

                <div class="error-msg <%= (request.getAttribute("registerGeneralErr")!=null) ? "visible-msg" : "" %>">
                  <%= request.getAttribute("registerGeneralErr") != null ? request.getAttribute("registerGeneralErr") : "" %>
                </div>

                <div class="success-msg <%= (request.getAttribute("registerSuccess")!=null) ? "visible-msg" : "" %>">
                  <%= request.getAttribute("registerSuccess") != null ? request.getAttribute("registerSuccess") : "" %>
                </div>

                <button class="btn" type="submit">Register</button>
              </form>
            </div>

          </div> <!-- forms-container -->
        </div> <!-- form-card -->

        <div class="reflection"></div>
      </div> <!-- form-wrap -->
    </div> <!-- card -->
  </div> <!-- wrap -->

  <script>
    // toggle UI based on server-sent activeForm
    const tabLogin = document.getElementById('tabLogin');
    const tabRegister = document.getElementById('tabRegister');
    const panelLogin = document.getElementById('panelLogin');
    const panelRegister = document.getElementById('panelRegister');

    function showForm(name){
      if(name === 'login'){
        tabLogin.classList.add('active'); tabRegister.classList.remove('active');
        panelLogin.classList.add('visible'); panelRegister.classList.remove('visible');
      } else {
        tabRegister.classList.add('active'); tabLogin.classList.remove('active');
        panelRegister.classList.add('visible'); panelLogin.classList.remove('visible');
      }
    }

    // read server-supplied initial form
    const activeForm = "<%= activeForm %>";
    showForm(activeForm);

    tabLogin.addEventListener('click', ()=>showForm('login'));
    tabRegister.addEventListener('click', ()=>showForm('register'));
  </script>
</body>
</html>