package org.datasource;

import org.datasource.csv.custcategories.CustomerCategoryView;
import org.datasource.csv.custcategories.CustomerEmpCategoryCSVViewBuilder;
import org.datasource.csv.views.customerbehavior.CustomerBehaviorView;
import org.datasource.csv.views.customerbehavior.CustomerBehaviorViewBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.logging.Logger;

/*
    REST Service URLs:

    Demo endpoint:
    http://localhost:8097/DSA-DOC-CSVService/rest/customers/CustomerEmployeesCategoryViewCSV

    Project DS2 endpoint:
    http://localhost:8097/DSA-DOC-CSVService/rest/customer-behavior/CustomerBehaviorViewCSV
*/

@RestController
@RequestMapping("/")
public class RESTViewServiceCSV {

	private static Logger logger = Logger.getLogger(RESTViewServiceCSV.class.getName());

	@Autowired
	private CustomerEmpCategoryCSVViewBuilder customerEmpCategoryCSVViewBuilder;

	@Autowired
	private CustomerBehaviorViewBuilder customerBehaviorViewBuilder;

	@RequestMapping(value = "/customers/CustomerEmployeesCategoryViewCSV", method = RequestMethod.GET,
			produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
	@ResponseBody
	public List<CustomerCategoryView> get_CustomerEmployeesCategoryViewCSV() throws Exception {
		List<CustomerCategoryView> viewList;

		if (this.customerEmpCategoryCSVViewBuilder.getViewList().isEmpty()) {
			viewList = this.customerEmpCategoryCSVViewBuilder.build().getViewList();
		} else {
			viewList = this.customerEmpCategoryCSVViewBuilder.getViewList();
		}

		return viewList;
	}

	@RequestMapping(value = "/customer-behavior/CustomerBehaviorViewCSV", method = RequestMethod.GET,
			produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE})
	@ResponseBody
	public List<CustomerBehaviorView> get_CustomerBehaviorViewCSV() {
		List<CustomerBehaviorView> viewList = this.customerBehaviorViewBuilder.build().getViewList();
		return viewList;
	}
}