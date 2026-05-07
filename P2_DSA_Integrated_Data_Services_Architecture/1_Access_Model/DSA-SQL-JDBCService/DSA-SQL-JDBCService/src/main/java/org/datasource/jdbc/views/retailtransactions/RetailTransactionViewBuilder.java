package org.datasource.jdbc.views.retailtransactions;

import org.datasource.jdbc.JDBCDataSourceConnector;
import org.springframework.stereotype.Service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Service
public class RetailTransactionViewBuilder {
    private static Logger logger = Logger.getLogger(RetailTransactionViewBuilder.class.getName());

    private String SQL_RETAIL_SELECT = """
            SELECT
                row_id,
                invoice_no,
                stock_code,
                REPLACE(description, '''', '') AS description,
                quantity,
                invoice_date,
                unit_price,
                customer_id,
                country,
                is_cancellation,
                is_return
            FROM retail_transactions_raw
            ORDER BY row_id
            LIMIT 50
            """;

    private List<RetailTransactionView> retailTransactionViewList = new ArrayList<>();

    private JDBCDataSourceConnector jdbcConnector;

    public RetailTransactionViewBuilder(JDBCDataSourceConnector jdbcConnector) {
        this.jdbcConnector = jdbcConnector;
    }

    public List<RetailTransactionView> getViewList() {
        return this.retailTransactionViewList;
    }

    public RetailTransactionViewBuilder build() {
        logger.info(">>> Building RetailTransactionView from retail_transactions_raw");

        try (Connection jdbcConnection = jdbcConnector.getConnection()) {
            PreparedStatement selectStmt = jdbcConnection.prepareStatement(SQL_RETAIL_SELECT);
            ResultSet rs = selectStmt.executeQuery();

            retailTransactionViewList = new ArrayList<>();

            while (rs.next()) {
                RetailTransactionView item = new RetailTransactionView(
                        rs.getLong("row_id"),
                        rs.getString("invoice_no"),
                        rs.getString("stock_code"),
                        rs.getString("description"),
                        rs.getInt("quantity"),
                        rs.getTimestamp("invoice_date") != null ? rs.getTimestamp("invoice_date").toString() : null,
                        rs.getBigDecimal("unit_price"),
                        rs.getObject("customer_id") != null ? rs.getLong("customer_id") : null,
                        rs.getString("country"),
                        rs.getBoolean("is_cancellation"),
                        rs.getBoolean("is_return")
                );

                this.retailTransactionViewList.add(item);
            }

        } catch (Exception ex) {
            ex.printStackTrace();
        }

        return this;
    }
}