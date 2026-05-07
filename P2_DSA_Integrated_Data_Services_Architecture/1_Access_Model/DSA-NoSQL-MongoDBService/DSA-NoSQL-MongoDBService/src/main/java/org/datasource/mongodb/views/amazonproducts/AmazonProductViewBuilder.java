package org.datasource.mongodb.views.amazonproducts;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import org.bson.Document;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Service
public class AmazonProductViewBuilder {

    private static final Logger logger = Logger.getLogger(AmazonProductViewBuilder.class.getName());

    private static final String MONGO_URI = "mongodb://localhost:27017";
    private static final String DATABASE_NAME = "mds";
    private static final String COLLECTION_NAME = "amazon_products";

    private List<AmazonProductView> amazonProductViewList = new ArrayList<>();

    public List<AmazonProductView> getViewList() {
        return this.amazonProductViewList;
    }

    public AmazonProductViewBuilder build() {
        logger.info(">>> Building AmazonProductView from MongoDB collection amazon_products");

        amazonProductViewList = new ArrayList<>();

        try (MongoClient mongoClient = MongoClients.create(MONGO_URI)) {
            MongoDatabase database = mongoClient.getDatabase(DATABASE_NAME);
            MongoCollection<Document> collection = database.getCollection(COLLECTION_NAME);

            int counter = 0;

            for (Document doc : collection.find().limit(100)) {
                AmazonProductView item = new AmazonProductView(
                        doc.getObjectId("_id") != null ? doc.getObjectId("_id").toString() : null,
                        clean(doc.getString("asin")),
                        clean(doc.getString("title")),
                        clean(doc.getString("brand_name")),
                        clean(doc.getString("availability")),
                        clean(doc.getString("category_main")),
                        clean(doc.getString("category_sub")),
                        clean(doc.getString("category_leaf")),
                        parseBigDecimal(doc.get("price_usd")),
                        parseBigDecimal(doc.get("list_price_usd")),
                        parseBigDecimal(doc.get("rating_stars")),
                        parseInteger(doc.get("rating_count")),
                        parseInteger(doc.get("recent_purchases_num")),
                        clean(doc.getString("seller_name")),
                        parseInteger(doc.get("review_count")),
                        clean(doc.getString("sample_review_title")),
                        clean(doc.getString("sample_review_text"))
                );

                amazonProductViewList.add(item);

                counter++;
                if (counter >= 100) {
                    break;
                }
            }

        } catch (Exception ex) {
            ex.printStackTrace();
        }

        return this;
    }

    private String clean(String value) {
        if (value == null) {
            return null;
        }

        return value
                .replace("\"", "")
                .replace("'", "")
                .replace("\n", " ")
                .replace("\r", " ")
                .trim();
    }

    private BigDecimal parseBigDecimal(Object value) {
        try {
            if (value == null) {
                return null;
            }

            if (value instanceof BigDecimal) {
                return (BigDecimal) value;
            }

            if (value instanceof Number) {
                return BigDecimal.valueOf(((Number) value).doubleValue());
            }

            String cleanedValue = clean(value.toString());
            if (cleanedValue == null || cleanedValue.isEmpty()) {
                return null;
            }

            return new BigDecimal(cleanedValue);
        } catch (Exception ex) {
            return null;
        }
    }

    private Integer parseInteger(Object value) {
        try {
            if (value == null) {
                return null;
            }

            if (value instanceof Number) {
                return ((Number) value).intValue();
            }

            String cleanedValue = clean(value.toString());
            if (cleanedValue == null || cleanedValue.isEmpty()) {
                return null;
            }

            return Integer.parseInt(cleanedValue);
        } catch (Exception ex) {
            return null;
        }
    }
}