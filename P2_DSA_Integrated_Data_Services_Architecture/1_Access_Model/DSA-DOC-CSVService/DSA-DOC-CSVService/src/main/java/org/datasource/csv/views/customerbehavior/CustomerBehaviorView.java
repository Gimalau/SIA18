package org.datasource.csv.views.customerbehavior;

import lombok.Value;

import java.math.BigDecimal;

@Value
public class CustomerBehaviorView {
    private Long orderId;
    private Long customerId;
    private Integer age;
    private String gender;
    private String productCategory;
    private BigDecimal purchaseAmount;
    private String paymentMethod;
    private Integer deliveryTimeDays;
    private Integer customerRating;
    private Boolean returnStatus;
}