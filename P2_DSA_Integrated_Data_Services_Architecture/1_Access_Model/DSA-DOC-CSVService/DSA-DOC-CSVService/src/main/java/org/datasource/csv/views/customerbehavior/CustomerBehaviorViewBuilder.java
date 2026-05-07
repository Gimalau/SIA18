package org.datasource.csv.views.customerbehavior;

import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Service
public class CustomerBehaviorViewBuilder {

    private static final Logger logger = Logger.getLogger(CustomerBehaviorViewBuilder.class.getName());

    private static final String CSV_FILE_PATH = "datasource/ds2_customer_behavior_clean.csv";

    private List<CustomerBehaviorView> customerBehaviorViewList = new ArrayList<>();

    public List<CustomerBehaviorView> getViewList() {
        return this.customerBehaviorViewList;
    }

    public CustomerBehaviorViewBuilder build() {
        logger.info(">>> Building CustomerBehaviorView from ds2_customer_behavior_clean.csv");

        customerBehaviorViewList = new ArrayList<>();

        try {
            InputStream inputStream = getClass().getClassLoader().getResourceAsStream(CSV_FILE_PATH);

            if (inputStream == null) {
                throw new RuntimeException("CSV file not found in resources: " + CSV_FILE_PATH);
            }

            try (BufferedReader br = new BufferedReader(
                    new InputStreamReader(inputStream, StandardCharsets.UTF_8))) {

                String line;
                boolean firstLine = true;
                int counter = 0;

                while ((line = br.readLine()) != null) {
                    if (firstLine) {
                        firstLine = false;
                        continue;
                    }

                    if (line.trim().isEmpty()) {
                        continue;
                    }

                    String[] values = line.split(",", -1);

                    if (values.length < 10) {
                        continue;
                    }

                    CustomerBehaviorView item = new CustomerBehaviorView(
                            parseLong(values[0]),
                            parseLong(values[1]),
                            parseInteger(values[2]),
                            clean(values[3]),
                            clean(values[4]),
                            parseBigDecimal(values[5]),
                            clean(values[6]),
                            parseInteger(values[7]),
                            parseInteger(values[8]),
                            parseBoolean(values[9])
                    );

                    customerBehaviorViewList.add(item);

                    counter++;
                    if (counter >= 100) {
                        break;
                    }
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
                .trim();
    }

    private Long parseLong(String value) {
        try {
            String cleanedValue = clean(value);
            if (cleanedValue == null || cleanedValue.isEmpty()) {
                return null;
            }
            return Long.parseLong(cleanedValue);
        } catch (Exception ex) {
            return null;
        }
    }

    private Integer parseInteger(String value) {
        try {
            String cleanedValue = clean(value);
            if (cleanedValue == null || cleanedValue.isEmpty()) {
                return null;
            }
            return Integer.parseInt(cleanedValue);
        } catch (Exception ex) {
            return null;
        }
    }

    private BigDecimal parseBigDecimal(String value) {
        try {
            String cleanedValue = clean(value);
            if (cleanedValue == null || cleanedValue.isEmpty()) {
                return null;
            }
            return new BigDecimal(cleanedValue);
        } catch (Exception ex) {
            return null;
        }
    }

    private Boolean parseBoolean(String value) {
        String cleanedValue = clean(value);

        if (cleanedValue == null || cleanedValue.isEmpty()) {
            return false;
        }

        return cleanedValue.equalsIgnoreCase("true")
                || cleanedValue.equalsIgnoreCase("yes")
                || cleanedValue.equalsIgnoreCase("1")
                || cleanedValue.equalsIgnoreCase("returned");
    }
}