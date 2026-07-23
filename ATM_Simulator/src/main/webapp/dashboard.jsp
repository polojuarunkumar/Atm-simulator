<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>City Bank - Dashboard</title>
    <link rel="stylesheet" type="text/css" href="css/dashboard.css">
</head>
<body>
    <% 
        if (session.getAttribute("user") == null) { 
            response.sendRedirect("index.jsp"); 
            return; 
        } 
    %>
    <div class="dashboard-container">
        <div class="app-header">
            <h2>Account Dashboard</h2>
            <a href="atm/logout" class="exit-link">Secure Exit</a>
        </div>

        <div class="balance-display">
            <div class="welcome-text">Welcome back, <%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "" %>!</div>
            <div class="balance-amount">
                Balance: ₹<%= session.getAttribute("currentBalance") != null ? ((java.math.BigDecimal) session.getAttribute("currentBalance")).setScale(2, java.math.RoundingMode.HALF_UP).toString() : "0.00" %>
            </div>
        </div>

        <% if (session.getAttribute("msg") != null) { %>
            <div class="status-banner">
                <%= session.getAttribute("msg") %>
            </div>
            <% session.removeAttribute("msg"); %>
        <% } %>

        <div class="panel-operations">
            <div class="full-width-row">
                <form action="atm/transaction" method="POST" class="pure-form">
                    <input type="hidden" name="type" value="enquiry">
                    <button type="submit" class="btn btn-enquiry" style="background-color: #28a745; color: white;">Balance Enquiry</button>
                </form>
            </div>
            <div class="split-input-row">
                <form action="atm/transaction" method="POST" class="action-form">
                    <input type="hidden" name="type" value="deposit">
                    <input type="number" name="amount" min="1" step="0.01" placeholder="Deposit Amount" required>
                    <button type="submit" class="btn btn-deposit" >Deposit</button>
                </form>
            </div>
            <div class="split-input-row">
                <form action="atm/transaction" method="POST" class="action-form">
                    <input type="hidden" name="type" value="withdraw">
                    <input type="number" name="amount" min="1" step="0.01" placeholder="Withdrawal Amount" required>
                    <button type="submit" class="btn btn-withdraw">Withdraw</button>
                </form>
            </div>
        </div>

        <div class="history-section">
            <h3>Recent Transactions</h3>
            <table class="history-table">
                <thead>
                    <tr>
                        <th>Date/Time</th>
                        <th>Type</th>
                        <th>Amount</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        @SuppressWarnings("unchecked")
                        List<atm.Transaction> history = (List<atm.Transaction>) session.getAttribute("transactionHistory");
                        if (history == null || history.isEmpty()) { 
                    %>
                        <tr><td colspan="4" style="text-align:center;">No records found.</td></tr>
                    <% 
                        } else { 
                            for (atm.Transaction tx : history) { 
                                String color = "Success".equals(tx.getStatus()) ? "#27ae60" : "#c0392b";
                                // Fixed formatting to handle BigDecimal amounts correctly
                                String formattedAmount = tx.getAmount() instanceof BigDecimal ? 
                                    ((BigDecimal) tx.getAmount()).setScale(2, java.math.RoundingMode.HALF_UP).toString() : 
                                    String.format("%.2f", tx.getAmount());
                    %>
                        <tr>
                            <td><%= tx.getDateTime() %></td>
                            <td><%= tx.getType() %></td>
                            <td>₹<%= formattedAmount %></td>
                            <td style="color: <%= color %>; font-weight:bold;"><%= tx.getStatus() %></td>
                        </tr>
                    <% 
                            } 
                        } 
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
