package atm;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Transaction {
    private final LocalDateTime timestamp;
    private final String type;
    private final BigDecimal amount;
    private final String status;

    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    public Transaction(LocalDateTime timestamp, String type, BigDecimal amount, String status) {
        this.timestamp = timestamp;
        this.type = type;
        this.amount = amount;
        this.status = status;
    }

    public String getDateTime() { return timestamp.format(formatter); }
    public String getType() { return type; }
    public BigDecimal getAmount() { return amount; }
    public String getStatus() { return status; }
}
