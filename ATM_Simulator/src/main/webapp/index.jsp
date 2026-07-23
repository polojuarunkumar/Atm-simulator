<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>City Bank - Login</title>
    <link rel="stylesheet" type="text/css" href="css/auth.css">
</head>
<body>
    <div class="auth-card">
        <h2>City Bank</h2>
        <div class="subtitle">Secure Internet Banking Portal</div>
        
        <% if (session.getAttribute("successMessage") != null) { %>
            <div class="alert-success">
                <%= session.getAttribute("successMessage") %>
            </div>
            <% session.removeAttribute("successMessage"); %>
        <% } %>

        <% if (session.getAttribute("errorMessage") != null) { %>
            <div class="alert-danger">
                <%= session.getAttribute("errorMessage") %>
            </div>
            <% session.removeAttribute("errorMessage"); %>
        <% } %>

        <form action="atm/login" method="POST">
            <div class="input-wrapper">
                <label>Username / Account ID</label>
                <input type="text" name="accountNumber" minlength="10" maxlength="10" required autocomplete="off">
            </div>
            <div class="input-wrapper">
                <label>Secure Password / PIN</label>
                <input type="password" name="pin" minlength="4" maxlength="4" required>
            </div>
            <button type="submit" class="btn-primary">Secure Login</button>
        </form>
        <div class="nav-link-wrapper">
            <a href="register.jsp" class="nav-link">Open New Account</a>
        </div>
    </div>
</body>
</html>
