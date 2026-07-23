<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>City Bank - Open an Account</title>
    <link rel="stylesheet" type="text/css" href="css/auth.css">
</head>
<body>
    <div class="auth-card">
        <h2>Open an Account</h2>
        <p class="subtitle">Create your 10-digit account number and secure PIN to join City Bank.</p>
        
        <% if (session.getAttribute("regError") != null) { %>
            <div class="alert-danger">
                <strong>Registration Failed:</strong> <%= session.getAttribute("regError") %>
            </div>
            <% session.removeAttribute("regError"); %>
        <% } %>

        <form action="atm/register" method="POST">
            <div class="input-wrapper">
                <label>Full Name</label>
                <input type="text" name="customerName" placeholder="e.g., John Doe" required autocomplete="off">
            </div>
            <div class="input-wrapper">
                <label>Choose Account Number</label>
                <input type="text" name="accountNumber" placeholder="e.g., 1234567890" minlength="10" maxlength="10" required autocomplete="off">
            </div>
            <div class="input-wrapper">
                <label>Set 4-Digit Secure PIN</label>
                <input type="password" name="pin" placeholder="••••" minlength="4" maxlength="4" required>
            </div>
            <div class="input-wrapper">
                <label>Initial Deposit Amount (₹)</label>
                <input type="number" name="initialBalance" placeholder="Minimum ₹500" min="500" step="0.01" required>
            </div>
            <button type="submit" class="btn-primary">Create Account</button>
        </form>
        <div class="nav-link-wrapper">
            <a href="index.jsp" class="nav-link">Back to Login</a>
        </div>
    </div>
</body>
</html>
