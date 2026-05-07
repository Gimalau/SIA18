package org.j4di;

import org.j4di.access.views.invoices.INVOICES_SALES_VIEW;
import org.j4di.access.views.invoices.INVOICES_VIEW;
import org.j4di.access.views.invoices.INVOICES_VIEW_Repository;
import org.j4di.analytical.views.OLAP_VIEW_SALES_DEP_CIT_CUST;
import org.j4di.analytical.views.OLAP_VIEW_SALES_DEP_CIT_CUST_Repository;
import org.j4di.integration.views.OLAP_DIM_CUSTS_CITIES_DEPTS;
import org.j4di.integration.views.OLAP_DIM_CUSTS_CITIES_DEPTS_Repository;
import org.j4di.integration.views.OLAP_FACTS_SALES_AMOUNT;
import org.j4di.integration.views.OLAP_FACTS_SALES_AMOUNT_Repository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

/*
	REST Service URL - original demo endpoints:
	http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/INVOICES_VIEW
	http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/INVOICES_VIEW/1001
	http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/INVOICES_SALES_VIEW

	http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/OLAP_DIM_CUSTS_CITIES_DEPTS
	http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/OLAP_FACTS_SALES_AMOUNT
	http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/OLAP_VIEW_SALES_DEP_CIT_CUST

	REST Service URL - DSA project analytical endpoints:
	http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/DSA_PRICE_BAND_360
	http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/DSA_SALES_ROLLUP_TIME_BAND
	http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/DSA_SALES_CUBE_COUNTRY_BAND
	http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/DSA_CUSTOMER_BEHAVIOR_SEGMENTS
	http://localhost:8096/DSA-WEB-RESTService/rest/OLAP/DSA_AMAZON_CATEGORY_STATS
*/

@RestController
@RequestMapping("/OLAP")
public class RESTViewService {

	private static Logger logger = Logger.getLogger(RESTViewService.class.getName());

	@Autowired
	private JdbcTemplate jdbcTemplate;

	@RequestMapping(value = "/ping", method = RequestMethod.GET,
			produces = {MediaType.TEXT_PLAIN_VALUE})
	@ResponseBody
	public String pingDataSource() {
		logger.info(">>>> DSA-WEB-SparkService:: RESTViewService is Up!");
		return "Ping response from DSA-WEB-SparkService!";
	}

	// -------------------------------------------------------------------------
	// Original demo access view endpoints
	// -------------------------------------------------------------------------

	@Autowired
	private INVOICES_VIEW_Repository INVOICES_VIEW_Repository;

	@GetMapping(value = "/INVOICES_VIEW",
			produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
	@ResponseBody
	public List<INVOICES_VIEW> get_INVOICES_VIEW() {
		List<INVOICES_VIEW> viewList = this.INVOICES_VIEW_Repository.get_INVOICES_VIEW();
		return viewList;
	}

	@GetMapping(value = "/INVOICES_VIEW/{customerId}",
			produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
	@ResponseBody
	public List<INVOICES_VIEW> get_INVOICES_VIEW_ByCustomerId(@PathVariable Long customerId) {
		List<INVOICES_VIEW> viewList = this.INVOICES_VIEW_Repository.get_INVOICES_VIEW_ByCustomerId(customerId);
		return viewList;
	}

	@GetMapping(value = "/INVOICES_SALES_VIEW",
			produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
	@ResponseBody
	public List<INVOICES_SALES_VIEW> get_InvoicesSalesView() {
		List<INVOICES_SALES_VIEW> viewList = this.INVOICES_VIEW_Repository.get_INVOICES_SALES_VIEW();
		return viewList;
	}

	// -------------------------------------------------------------------------
	// Original demo integration view endpoints
	// -------------------------------------------------------------------------

	@Autowired
	private OLAP_DIM_CUSTS_CITIES_DEPTS_Repository OLAP_DIM_CUSTS_CITIES_DEPTS_Repository;

	@Autowired
	private OLAP_FACTS_SALES_AMOUNT_Repository OLAP_FACTS_SALES_AMOUNT_Repository;

	@GetMapping(value = "/OLAP_DIM_CUSTS_CITIES_DEPTS",
			produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
	@ResponseBody
	public List<OLAP_DIM_CUSTS_CITIES_DEPTS> get_OLAP_DIM_CUSTS_CITIES_DEPTS() {
		List<OLAP_DIM_CUSTS_CITIES_DEPTS> viewList =
				this.OLAP_DIM_CUSTS_CITIES_DEPTS_Repository.get_OLAP_DIM_CUSTS_CITIES_DEPTS();
		return viewList;
	}

	@GetMapping(value = "/OLAP_FACTS_SALES_AMOUNT",
			produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
	@ResponseBody
	public List<OLAP_FACTS_SALES_AMOUNT> get_OLAP_FACTS_SALES_AMOUNT() {
		List<OLAP_FACTS_SALES_AMOUNT> viewList =
				this.OLAP_FACTS_SALES_AMOUNT_Repository.get_OLAP_FACTS_SALES_AMOUNT();
		return viewList;
	}

	// -------------------------------------------------------------------------
	// Original demo analytical view endpoint
	// -------------------------------------------------------------------------

	@Autowired
	private OLAP_VIEW_SALES_DEP_CIT_CUST_Repository OLAP_VIEW_SALES_DEP_CIT_CUST_Repository;

	@GetMapping(value = "/OLAP_VIEW_SALES_DEP_CIT_CUST",
			produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
	@ResponseBody
	public List<OLAP_VIEW_SALES_DEP_CIT_CUST> get_OLAP_VIEW_SALES_DEP_CIT_CUST() {
		List<OLAP_VIEW_SALES_DEP_CIT_CUST> viewList =
				this.OLAP_VIEW_SALES_DEP_CIT_CUST_Repository.get_OLAP_VIEW_SALES_DEP_CIT_CUST();
		return viewList;
	}

	// -------------------------------------------------------------------------
	// DSA Project Analytical REST Endpoints
	// These endpoints expose SparkSQL OLAP views created in SparkSQL_OLAP.sql
	// -------------------------------------------------------------------------

	@GetMapping(value = "/DSA_PRICE_BAND_360",
			produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
	@ResponseBody
	public List<Map<String, Object>> get_DSA_PRICE_BAND_360() {
		String sql = "SELECT * FROM dsa_price_band_360_v ORDER BY band_id";
		return jdbcTemplate.queryForList(sql);
	}

	@GetMapping(value = "/DSA_SALES_ROLLUP_TIME_BAND",
			produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
	@ResponseBody
	public List<Map<String, Object>> get_DSA_SALES_ROLLUP_TIME_BAND() {
		String sql = "SELECT * FROM dsa_sales_rollup_time_band_v LIMIT 50";
		return jdbcTemplate.queryForList(sql);
	}

	@GetMapping(value = "/DSA_SALES_CUBE_COUNTRY_BAND",
			produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
	@ResponseBody
	public List<Map<String, Object>> get_DSA_SALES_CUBE_COUNTRY_BAND() {
		String sql = "SELECT * FROM dsa_sales_cube_country_band_v LIMIT 50";
		return jdbcTemplate.queryForList(sql);
	}

	@GetMapping(value = "/DSA_CUSTOMER_BEHAVIOR_SEGMENTS",
			produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
	@ResponseBody
	public List<Map<String, Object>> get_DSA_CUSTOMER_BEHAVIOR_SEGMENTS() {
		String sql = "SELECT * FROM dsa_customer_behavior_segments_v LIMIT 50";
		return jdbcTemplate.queryForList(sql);
	}

	@GetMapping(value = "/DSA_AMAZON_CATEGORY_STATS",
			produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
	@ResponseBody
	public List<Map<String, Object>> get_DSA_AMAZON_CATEGORY_STATS() {
		String sql = "SELECT * FROM dsa_amazon_category_stats_v LIMIT 50";
		return jdbcTemplate.queryForList(sql);
	}
}