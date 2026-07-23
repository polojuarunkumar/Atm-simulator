package atm;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import org.hibernate.LockMode;
import org.hibernate.Session;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/atm/*")
public class ATMServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getPathInfo();
        HttpSession httpSession = request.getSession();
        Session dbSession = HibernateUtil.getSessionFactory().openSession();
        org.hibernate.Transaction tx = null;

        try {
            if ("/login".equals(action)) {
                String accNum = request.getParameter("accountNumber");
                String pin = request.getParameter("pin");
                
                Account account = dbSession.get(Account.class, accNum);
                if (account != null && account.getPin().equals(pin)) {
                    httpSession.setAttribute("user", accNum);
                    httpSession.setAttribute("userName", account.getCustomerName());
                    httpSession.setAttribute("currentBalance", account.getBalance());
                    response.sendRedirect("../dashboard.jsp");
                } else {
                    httpSession.setAttribute("errorMessage", "Invalid Account Number or Verification PIN Code.");
                    response.sendRedirect("../index.jsp");
                }
            } 
            else if ("/register".equals(action)) {
                String name = request.getParameter("customerName");
                String accNum = request.getParameter("accountNumber");
                String pin = request.getParameter("pin");
                String rawBalance = request.getParameter("initialBalance");

                if (name == null || name.trim().isEmpty() || accNum == null || accNum.trim().length() != 10 || pin == null || pin.trim().length() != 4 || rawBalance == null) {
                    httpSession.setAttribute("regError", "Invalid registration field layouts provided.");
                    response.sendRedirect("../register.jsp");
                    return;
                }

                tx = dbSession.beginTransaction();
                Account existing = dbSession.get(Account.class, accNum, LockMode.PESSIMISTIC_WRITE);
                
                if (existing != null) {
                    tx.rollback();
                    httpSession.setAttribute("regError", "Account Number is already registered.");
                    response.sendRedirect("../register.jsp");
                } else {
                    BigDecimal initialBalance = new BigDecimal(rawBalance);
                    Account newAccount = new Account(accNum, name, pin, initialBalance);
                    dbSession.persist(newAccount);
                    tx.commit();
                    httpSession.setAttribute("successMessage", "Account created successfully!");
                    response.sendRedirect("../index.jsp");
                }
            } 
            else if ("/transaction".equals(action)) {
                String accNum = (String) httpSession.getAttribute("user");
                if (accNum == null) {
                    response.sendRedirect("../index.jsp");
                    return;
                }

                String type = request.getParameter("type");
                String amountStr = request.getParameter("amount");
                BigDecimal amount = (amountStr != null && !amountStr.isEmpty()) ? new BigDecimal(amountStr) : BigDecimal.ZERO;

                @SuppressWarnings("unchecked")
                List<Transaction> history = (List<Transaction>) httpSession.getAttribute("transactionHistory");
                if (history == null) history = new ArrayList<>();

                tx = dbSession.beginTransaction();
                // Avoid Double-Spending Vulnerability via Row Locking
                Account account = dbSession.get(Account.class, accNum, LockMode.PESSIMISTIC_WRITE);

                if (account != null) {
                    if ("enquiry".equals(type)) {
                        httpSession.setAttribute("msg", "Balance enquiry processed successfully.");
                        tx.commit();
                    } else if ("deposit".equals(type) && amount.compareTo(BigDecimal.ZERO) > 0) {
                        account.setBalance(account.getBalance().add(amount));
                        dbSession.merge(account);
                        tx.commit();
                        history.add(0, new Transaction(LocalDateTime.now(), "Deposit", amount, "Success"));
                        httpSession.setAttribute("currentBalance", account.getBalance());
                        httpSession.setAttribute("msg", "Successfully deposited ₹" + account.getBalance());
                    } else if ("withdraw".equals(type) && amount.compareTo(BigDecimal.ZERO) > 0) {
                        if (account.getBalance().compareTo(amount) >= 0) {
                            account.setBalance(account.getBalance().subtract(amount));
                            dbSession.merge(account);
                            tx.commit();
                            history.add(0, new Transaction(LocalDateTime.now(), "Withdrawal", amount, "Success"));
                            httpSession.setAttribute("currentBalance", account.getBalance());
                            httpSession.setAttribute("msg", "Successfully withdrew ₹" + amount);
                        } else {
                            tx.commit(); // Close atomic check window safely
                            history.add(0, new Transaction(LocalDateTime.now(), "Withdrawal", amount, "Failed (Insufficient Funds)"));
                            httpSession.setAttribute("msg", "Error: Insufficient balance!");
                        }
                    } else {
                        tx.rollback();
                        httpSession.setAttribute("msg", "Error: Out-of-bounds monetary values parameter.");
                    }
                } else {
                    tx.rollback();
                    httpSession.setAttribute("msg", "Error: Target account record missing.");
                }
                
                httpSession.setAttribute("transactionHistory", history);
                response.sendRedirect("../dashboard.jsp");
            }
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            e.printStackTrace();
            httpSession.setAttribute("msg", "An unexpected transaction fault structure processing error occurred.");
            response.sendRedirect("../dashboard.jsp");
        } finally {
            dbSession.close();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getPathInfo();
        HttpSession httpSession = request.getSession();
        if ("/logout".equals(action)) {
            httpSession.invalidate();
            response.sendRedirect("../index.jsp");
        }
    }
}
