package org.datasource.jdbc.views.retailtransactions;

import lombok.Value;

import java.math.BigDecimal;

@Value
public class RetailTransactionView {
    private Long rowId;
    private String invoiceNo;
    private String stockCode;
    private String description;
    private Integer quantity;
    private String invoiceDate;
    private BigDecimal unitPrice;
    private Long customerId;
    private String country;
    private Boolean isCancellation;
    private Boolean isReturn;
}