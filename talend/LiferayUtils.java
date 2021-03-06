package routines;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import routines.system.JSONArray;
import routines.system.JSONObject;


public class LiferayUtils {
    
    /**
     * setArticleFields: return the contentFields array for the article structure in JSON.
     * 
     * {talendTypes} String
     * 
     * {Category} Liferay Utils
     * 
     * {param} string("title") input: The article's title.
     * {param} string("body") input: The article's body.
     * {param} string("author") input: The author of the article.
     * {param} string("publicationDate") input: The publication date of the article.
     */
    public static String setArticleFields(String title, String body, String author, Date publicationDate) {
    	JSONArray contentFields = new JSONArray();
    	
    	JSONObject titleField = new JSONObject();
    	titleField.put("name", "title");
    	JSONObject titleFieldContentFieldValue = new JSONObject();
    	titleFieldContentFieldValue.put("data", title);
    	titleField.put("contentFieldValue", titleFieldContentFieldValue);
    	contentFields.put(titleField);
    	
    	JSONObject bodyField = new JSONObject();
    	bodyField.put("name", "body");
    	JSONObject bodyFieldContentFieldValue = new JSONObject();
    	bodyFieldContentFieldValue.put("data", body);
    	bodyField.put("contentFieldValue", bodyFieldContentFieldValue);
    	contentFields.put(bodyField);
    	
    	JSONObject authorField = new JSONObject();
    	authorField.put("name", "author");
    	JSONObject authorFieldContentFieldValue = new JSONObject();
    	authorFieldContentFieldValue.put("data", author);
    	authorField.put("contentFieldValue", authorFieldContentFieldValue);
    	contentFields.put(authorField);
    	
    	JSONObject publicationDateField = new JSONObject();
    	publicationDateField.put("name", "publicationDate");
    	JSONObject publicationDateFieldContentFieldValue = new JSONObject();
    	DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    	publicationDateFieldContentFieldValue.put("data", dateFormat.format(publicationDate));
    	publicationDateField.put("contentFieldValue", publicationDateFieldContentFieldValue);
    	contentFields.put(publicationDateField);
    	
        return contentFields.toString();
    }
   
}
