package org.datasource.mongodb.views.amazonproducts;

import lombok.Value;

import java.math.BigDecimal;

@Value
public class AmazonProductView {
    private String mongoId;
    private String asin;
    private String title;
    private String brandName;
    private String availability;
    private String categoryMain;
    private String categorySub;
    private String categoryLeaf;
    private BigDecimal priceUsd;
    private BigDecimal listPriceUsd;
    private BigDecimal ratingStars;
    private Integer ratingCount;
    private Integer recentPurchasesNum;
    private String sellerName;
    private Integer reviewCount;
    private String sampleReviewTitle;
    private String sampleReviewText;
}