
CREATE DATABASE liferay_vision CHARACTER SET UTF8;

USE liferay_vision;

DROP TABLE IF EXISTS blogs;

CREATE TABLE blogs (
  id INT NOT NULL AUTO_INCREMENT,
  title varchar(150) NOT NULL,
  body longtext,
  author varchar(50) DEFAULT NULL,
  publicationDate date DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO blogs
(title, body, author, publicationDate)
VALUES 
("New 7.4 Feature: GraphQL namespaces", "Background\n----------\n\nAs our API ecosystem has grown bigger, it has been more frequent to fall into conflicts in types and query/mutation names between all of our apps. This is a consequence of GraphQL sharing all of our apps on a global namespace and unique endpoint.\n\nThis is a common problem with systems that are big enough or serve as a facade for other services, as Liferay does with client custom APIs, that arises the need to have namespaces, a missing piece in the GraphQL spec.\n\nThe debate about namespaces has been going on for many years. There is an [open issue](https://github.com/graphql/graphql-spec/issues/163) about namespaces in GraphQL spec from the 11th April 2016, and it does not seem to end soon enough.\n\nIn Liferay, we have decided to address this issue for our customers and ourselves. We have considered two options:\n\n1.  Divide the global namespace allowing to serve GraphQL apps from different endpoints.\n\n2.  Provide syntax to query a namespace and infrastructure to publish our app in the selected namespace.\n\nWe have chosen option 2 as the simple and more effective way of solving this issue.\n\nThe GraphQL namespac\es are a custom Liferay implementation and go against some of the major advantages of the GraphQL technology itself, as having a global namespace where you can easily find and navigate through all the possible queries and mutation with a simple syntax, so it should be used carefully, considering benefits and drawbacks.\n\nFeature\n-------\n\nThe GraphQL namespace feature allows selecting a namespace that will hold all the queries, mutations, and types of the application, avoiding conflicts with other apps. To select the namespace you should add the configuration parameter graphQLNamespace to your *rest-config.yaml* file.\n\nOnce you do so, you can check the generated code uses this value in the implementation of the *getGraphQLNamespace* method inside the *ServletDataImpl* class.\n\nIn terms of usage, you should add the namespace after the query or mutation to select the namespace you want, and then you will have available all the queries, mutations, and types of the namespace.\n\n```\nquery {\n  admin {\n   displayPageTemplates(siteKey: \"20124\") {\n      items {\n        title\n      }\n    }\n  }\n}\n```\n\n### How to use it\n\nTo select a namespace for your application:\n\n1.  Go to the implementation module\n\n2.  Open the r*est-config.yaml* file\n\n3.  Add the graphQLNamespace with the desired namespace name\n\n    ```\n    graphQLNamespace: <namespace name>\n    ```\n\n4.  Execute REST Builder\n\n5.  All your queries and mutation will be published in the selected namespace\n\nTo make a query or mutation to your application, use your namespace in a level below query or mutation object. Like:\n\n```\nquery {\n  <namespace name> {\n   ...\n  }\n}\n```\n\nGraphQL namespaces and GraphQL extensions\n-----------------------------------------\n\nThe GraphQL namespace has been included in the *GraphQLContributor* interface, making it available to your GraphQL extensions. You can implement the *getGraphQLNamespace* method returning the desired value.\n\n```\npublic class MyGraphQLContributor implements GraphQLContributor {\n  ...\n\n  @Override\n  public String getGraphQLNamespace() {\n    return \"<namespace name>\";\n  }\n\n  ...\n}\n```\n\nThe namespace in the GraphQL extensions is disabled by default.\n\nHeadless Admin Content API\n--------------------------\n\nThe first use case inside Liferay that applies this feature is the *Headless Admin Content API*, which is published inside the **admin** namespace.\n\nIt was needed because the *Headless Admin Content API* uses the *Headless Delivery API* same concepts but with a different meaning, same concepts with an administrator perspective. It is the case of the *StructuredContent* entity, where the *Headless Admin Content API* offers additional information relevant for the administrator, like version information.\n\nThis is not a problem in REST, as each of the *StructuredContent* concepts exists on its own namespace and unique endpoints, but it is a problem for GraphQL because of the global namespace, that causes a conflict between them.\n\nUsing the **admin** namespace, we can disambiguate between them and avoid conflict. *StructuredContent* will have a general meaning in the global namespace, and a more concrete meaning relevant for administrators in the **admin** namespace.\n\nIf you need more details about the feature and implementation you can check the [LPS-126722](https://issues.liferay.com/browse/LPS-126722) epic in Jira", "Javier de Arcos", "2021-03-08"),
("New 7.4 Feature: Site Pages APIs, first step", "One of the main missing pieces in our API space are endpoints related to Site Pages. In this 7.4 release, we are working hard to provide this important feature to our users, to allow them to build and managing site pages from our Headless APIs.\n\nAs a first step, in the **7.4 GA1** release, we have added support to get information about pages, experiences, and display page templates.\n\nGetting information about pages through Headless Delivery API\n-------------------------------------------------------------\n\nPages are the heart of your site and are used to display content and applications to your users.\n\nThe entry point to this group of endpoints is the /sites/{siteId}/site-pages, where you can retrieve all the **public pages** of a site with a valid site identifier or site key. In GraphQL you should use the sitePages query passing the site key argument. The pages contain information like the title, page type, page settings, creator, ... The site pages endpoint and query support pagination, filter, search, sort, and multi-faceted aggregation.\n\nThis is an example of a request/response with the home and search default pages:\n\ncurl -X 'GET' 'http://localhost:8080/o/headless-delivery/v1.0/sites/guest/site-pages/home' -u 'test@liferay.com:test'\n\n```\n{\n  \"actions\": {\n    \"get\": {\n      \"method\": \"GET\",\n      \"href\": \"http://localhost:8080/o/headless-delivery/v1.0/sites/20125/site-pages\"\n    }\n  },\n  \"facets\": [],\n  \"items\": [\n    {\n      \"actions\": {\n        \"get-experiences\": {\n          \"method\": \"GET\",\n          \"href\": \"http://localhost:8080/o/headless-delivery/v1.0/sites/20125/site-pages/{friendlyUrlPath}/experiences\"\n        },\n        \"get\": {\n          \"method\": \"GET\",\n          \"href\": \"http://localhost:8080/o/headless-delivery/v1.0/sites/20125/site-pages/{friendlyUrlPath}\"\n        },\n        \"get-rendered-page\": {\n          \"method\": \"GET\",\n          \"href\": \"http://localhost:8080/o/headless-delivery/v1.0/sites/20125/site-pages/{friendlyUrlPath}/rendered-page\"\n        }\n      },\n      \"availableLanguages\": [\n        \"en-US\"\n      ],\n      \"creator\": {\n        \"additionalName\": \"\",\n        \"contentType\": \"UserAccount\",\n        \"familyName\": \"Test\",\n        \"givenName\": \"Test\",\n        \"id\": 20129,\n        \"name\": \"Test Test\"\n      },\n      \"customFields\": [],\n      \"dateCreated\": \"2021-04-21T12:24:17Z\",\n      \"dateModified\": \"2021-04-21T12:24:18Z\",\n      \"datePublished\": \"2021-04-21T12:24:18Z\",\n      \"friendlyUrlPath\": \"/92c0734b-6526-3e8c-683e-fb2fc26c407f\",\n      \"keywords\": [],\n      \"pageSettings\": {\n        \"hiddenFromNavigation\": true,\n        \"seoSettings\": {\n          \"description\": \"\",\n          \"htmlTitle\": \"\",\n          \"robots\": \"\",\n          \"seoKeywords\": \"\"\n        }\n      },\n      \"pageType\": \"Content Page\",\n      \"renderedPage\": {\n        \"renderedPageURL\": \"http://localhost:8080/o/headless-delivery/v1.0/sites/20125/site-pages/92c0734b-6526-3e8c-683e-fb2fc26c407f/rendered-page\"\n      },\n      \"siteId\": 20125,\n      \"taxonomyCategoryBriefs\": [],\n      \"title\": \"Home\",\n      \"uuid\": \"3cc94c10-7ebf-39e3-ad12-6938ad799b8c\"\n    },\n    {\n      \"actions\": {\n        \"get\": {\n          \"method\": \"GET\",\n          \"href\": \"http://localhost:8080/o/headless-delivery/v1.0/sites/20125/site-pages/{friendlyUrlPath}\"\n        },\n        \"get-rendered-page\": {\n          \"method\": \"GET\",\n          \"href\": \"http://localhost:8080/o/headless-delivery/v1.0/sites/20125/site-pages/{friendlyUrlPath}/rendered-page\"\n        }\n      },\n      \"availableLanguages\": [\n        \"ar-SA\",\n        \"ca-ES\",\n        \"de-DE\",\n        \"en-US\",\n        \"es-ES\",\n        \"fi-FI\",\n        \"fr-FR\",\n        \"hu-HU\",\n        \"ja-JP\",\n        \"nl-NL\",\n        \"pt-BR\",\n        \"sv-SE\",\n        \"zh-CN\"\n      ],\n      \"customFields\": [],\n      \"dateCreated\": \"2021-04-21T12:24:34Z\",\n      \"dateModified\": \"2021-04-21T12:24:34Z\",\n      \"datePublished\": \"2021-04-21T12:24:34Z\",\n      \"friendlyUrlPath\": \"/search\",\n      \"keywords\": [],\n      \"pageSettings\": {\n        \"hiddenFromNavigation\": true,\n        \"seoSettings\": {\n          \"description\": \"Display search results with a default set of facets.\",\n          \"htmlTitle\": \"\",\n          \"robots\": \"\",\n          \"seoKeywords\": \"\"\n        }\n      },\n      \"pageType\": \"Widget Page\",\n      \"renderedPage\": {\n        \"renderedPageURL\": \"http://localhost:8080/o/headless-delivery/v1.0/sites/20125/site-pages/search/rendered-page\"\n      },\n      \"siteId\": 20125,\n      \"taxonomyCategoryBriefs\": [],\n      \"title\": \"Search\",\n      \"uuid\": \"074db0b9-3dc9-2009-a675-ad64e19e665b\"\n    }\n  ],\n  \"lastPage\": 1,\n  \"page\": 1,\n  \"pageSize\": 20,\n  \"totalCount\": 2\n}\n```\n\nTo access detailed information about a specific page you should use the endpoint sites/{siteId}/site-pages/{friendlyURL} using its friendly URL. The correspondent GraphQL query is sitePage. There you will find all the information presented in the collection endpoint, plus the page definition.\n\nThe **page definition** contains the structure of all the elements in the page, including information about element type, content and style. The page information and definition that you receive depend on the experience selected for the user making the request. We will talk about experiences in the next section.\n\nAn example of the welcome paragraph page element definition, included in the default home page definition, is:\n\n```\n{\n  \"definition\": {\n    \"fragment\": {\n      \"key\": \"BASIC_COMPONENT-heading\"\n    },\n    \"fragmentConfig\": {\n      \"headingLevel\": \"h1\"\n    },\n    \"fragmentFields\": [{\n      \"id\": \"element-text\",\n      \"value\": {\n        \"fragmentLink\": {},\n        \"text\": {\n          \"value\": \"Welcome to Liferay Portal\"\n        }\n      }\n    }],\n    \"fragmentStyle\": {\n      \"backgroundFragmentImage\": {},\n      \"borderRadius\": \"\",\n      \"borderWidth\": \"0\",\n      \"fontFamily\": \"\",\n      \"fontSize\": \"\",\n      \"fontWeight\": \"\",\n      \"height\": \"\",\n      \"marginBottom\": \"3\",\n      \"marginLeft\": \"\",\n      \"marginRight\": \"\",\n      \"marginTop\": \"0\",\n      \"maxHeight\": \"\",\n      \"maxWidth\": \"\",\n      \"minHeight\": \"\",\n      \"minWidth\": \"\",\n      \"opacity\": \"100\",\n      \"overflow\": \"\",\n      \"paddingBottom\": \"\",\n      \"paddingLeft\": \"\",\n      \"paddingRight\": \"\",\n      \"paddingTop\": \"\",\n      \"shadow\": \"\",\n      \"textAlign\": \"left\",\n      \"width\": \"\"\n    },\n    \"fragmentViewports\": [{\n      \"fragmentViewportStyle\": {\n        \"marginTop\": \"2\"\n      },\n      \"id\": \"portraitMobile\"\n    }, {\n      \"fragmentViewportStyle\": {\n        \"marginBottom\": \"3\"\n      },\n      \"id\": \"tablet\"\n    }]\n  },\n  \"type\": \"Fragment\"\n}\n```\n\nGetting experiences\n-------------------\n\nExperiences are the most important piece of Liferay's Segmentation and Personalization. They dynamically change the page layout and content based on who is viewing the page, enhancing user experience.\n\nExperiences are also available through the **Headless Delivery API**, providing the page's active experiences and applying them to the page to return the page definition and content customized for the selected experience. To retrieve the experiences of a page you should make a GET request to the sites/{siteId}/site-pages/{friendlyURL}/experiences endpoint. In GraphQL, you should use the sitePageFriendlyUrlPathExperiences query.\n\nIt is also possible to select a specific experience to receive the customized page, accessing to the sites/{siteId}/site-pages/{friendlyURL}/experiences/{experienceKey} endpoint or with the sitePageExperienceExperienceKey query.\n\nExperiences are applied transparently to the page endpoints explained in the previous section, selecting the right experience for the user making the request.\n\nRendered pages\n--------------\n\nIt is also possible to access the rendered page using the **rendered-page** endpoints, receiving a completely valid HTML page that you can embed in your application.\n\nYou can request the render of a page in the sites/20126/site-pages/home/rendered-page endpoint, to have the page rendered with the experience of the user making the request, or request the rendered page of a specific experience if you have access to it in the sites/20126/site-pages/home/experiences/0/rendered-page endpoint. The sitePageRenderedPage and the sitePageExperienceExperienceKeyRenderedPage are the correspondent GraphQL queries.\n\nHere you have an example of a request/response of the home page rendered:\n\ncurl -X 'GET' 'http://localhost:8080/o/headless-delivery/v1.0/sites/guest/site-pages/home/rendered-page' -u 'test@liferay.com:test'\n\nYou can access the HTML code of the response [here](https://gist.github.com/javierdearcos/bc591e927da6cd1bd60e1bb6df5e8574)\n\nDisplay Page Templates\n----------------------\n\nDisplay Page Templates are a great way to create standard, reusable formats to control the look and feel of your content.\n\nYou can retrieve all the display page templates of a site through the **Headless Admin Content API**, using the /sites/{siteId}/display-page-templates endpoint or the displayPageTemplates query in the Admin namespace in GraphQL. The information includes the title, creator, template settings, and page definition among others.\n\nTo get a specific display page template you should make a request to the sites/{siteId}/display-page-templates/{displayPageTemplateKey} using its key or use the displayPageTemplate query passing the site key and the display page template key arguments.\n\nTry it out!\n-----------\n\nAs we always recommend, the best way to learn about these new features is to try them out in [the API Explorer](https://liferay.dev/blogs/-/blogs/the-api-explorer). Access to http://localhost:8080/o/api in your browser, start playing around getting all kinds of information about your site pages and give us feedback about it!", "Javier de Arcos", "2021-04-22"),
("New 7.4 Feature: Manage permissions with Liferay Headless APIs", "For the 7.4 release, we have added endpoints to the Headless APIs to manage the entity permissions.\n\nAs the Portal does, these permissions can apply at the collection level (a group of entities) or at the entity level (an individual entity).\n\nWith the Headless APIs you are able to view the current permissions with a GET request and to modify the permissions with a PUT request specifying the actions that are allowed by role.\n\nThese endpoints are available in Headless Delivery and Headless Admin Taxonomy APIs.\n\nUsage\n-----\n\n### View permissions\n\nTo view the permissions of a collection of entities, like all the structured contents of a site, you should make a **GET** request to the collection URL followed by the /permissions path chunk. The URL to get the permissions of the Structured Contents of a site is [http://localhost:8080/o/headless-delivery/v1.0/sites/{SITE_ID}/structured-contents/permissions](http://localhost:8080/o/headless-delivery/v1.0/sites/20125/structured-contents/permissions)\n\nAn example of a response should be:\n\n```\n{\n  \"actions\": {\n    \"get\": {\n      \"method\": \"GET\",\n      \"href\": \"http://localhost:8080/o/headless-delivery/v1.0/sites/20125/structured-contents/permissions\"\n    },\n    \"replace\": {\n      \"method\": \"PUT\",\n      \"href\": \"http://localhost:8080/o/headless-delivery/v1.0/sites/20125/structured-contents/permissions\"\n    }\n  },\n  \"facets\": [],\n  \"items\": [\n    {\n      \"actionIds\": [\n        \"PERMISSIONS\",\n        \"ADD_FEED\",\n        \"ADD_TEMPLATE\",\n        \"UPDATE\",\n        \"ADD_ARTICLE\",\n        \"VIEW\",\n        \"SUBSCRIBE\",\n        \"ADD_FOLDER\",\n        \"ADD_STRUCTURE\"\n      ],\n      \"roleName\": \"Owner\"\n    },\n    {\n      \"actionIds\": [\n        \"VIEW\"\n      ],\n      \"roleName\": \"Site Member\"\n    },\n    {\n      \"actionIds\": [\n        \"VIEW\"\n      ],\n      \"roleName\": \"Guest\"\n    }\n  ],\n  \"lastPage\": 1,\n  \"page\": 1,\n  \"pageSize\": 3,\n  \"totalCount\": 3\n}\n```\n\nIf you want to view the permissions of a specific entity, you should use the entity URL followed by /permissions. To get the permissions of a structured content you should make a **GET** request to the URL [http://localhost:8080/o/headless-delivery/v1.0/structured-contents/{STRUCTUREC_CONTENT_ID}/permissions](http://localhost:8080/o/headless-delivery/v1.0/structured-contents/98707/permissions)\n\nThe response should be something like:\n\n```\n{\n  \"actions\": {\n    \"get\": {\n      \"method\": \"GET\",\n      \"href\": \"http://localhost:8080/o/headless-delivery/v1.0/structured-contents/98707/permissions\"\n    },\n    \"replace\": {\n      \"method\": \"PUT\",\n      \"href\": \"http://localhost:8080/o/headless-delivery/v1.0/structured-contents/98707/permissions\"\n    }\n  },\n  \"facets\": [],\n  \"items\": [\n    {\n      \"actionIds\": [\n        \"UPDATE_DISCUSSION\",\n        \"DELETE\",\n        \"PERMISSIONS\",\n        \"EXPIRE\",\n        \"DELETE_DISCUSSION\",\n        \"UPDATE\",\n        \"VIEW\",\n        \"SUBSCRIBE\",\n        \"ADD_DISCUSSION\"\n      ],\n      \"roleName\": \"Owner\"\n    },\n    {\n      \"actionIds\": [\n        \"VIEW\",\n        \"ADD_DISCUSSION\"\n      ],\n      \"roleName\": \"Site Member\"\n    },\n    {\n      \"actionIds\": [\n        \"VIEW\",\n        \"ADD_DISCUSSION\"\n      ],\n      \"roleName\": \"Guest\"\n    }\n  ],\n  \"lastPage\": 1,\n  \"page\": 1,\n  \"pageSize\": 3,\n  \"totalCount\": 3\n}\n```\n\nIn both cases, you are able to specify the roles you want to view using the **roleNames** URL parameter and fill it with the role names separated by commas. An example using *curl* is:\n\n```\ncurl \"http://localhost:8080/o/headless-delivery/v1.0/sites/20125/structured-contents/permissions?roleNames=Guest,Owner\" -u 'test@liferay.com:test'\n```\n\n### Update permissions\n\nIt is also possible to update the permissions using the Headless APIs. To update the permissions you should make a **PUT** request to the desired URL (the same ones we were using above) with the following body format: an array of the permission object, that is defined by the *roleName* and the array of allowed *actionIds*. For example:\n\n```\n[\n    {\n      \"actionIds\": [\n        \"PERMISSIONS\",\n        \"ADD_FEED\",\n        \"ADD_TEMPLATE\",\n        \"UPDATE\",\n        \"ADD_ARTICLE\",\n        \"VIEW\",\n        \"SUBSCRIBE\",\n        \"ADD_FOLDER\",\n        \"ADD_STRUCTURE\"\n      ],\n      \"roleName\": \"Owner\"\n    },\n    {\n      \"actionIds\": [\n        \"ADD_ARTICLE\",\n        \"VIEW\",\n        \"SUBSCRIBE\"\n      ],\n      \"roleName\": \"Site Member\"\n    }\n  ]\n```\n\nThe response should be the updated permissions of the resource.\n\nConclusion\n----------\n\nLiferay Headless APIs keep growing to let you handle more features in a decoupled way. This time they grew to let you manage the permissions of all your entities in a similar way you would do using the Portal.\n\nRemember you can always rely on the OpenAPI definition and in the [API Explorer](https://liferay.dev/en/b/the-api-explorer) to check and test our APIs. **Try it out and give us feedback!**\n\nIf you need more details about the feature and implementation you can check the [LPS-119062](https://issues.liferay.com/browse/LPS-119062) epic in Jira", "Javier de Arcos", "2021-06-25"),
("New 7.4 Feature: Questions Moderation System", "As a part of the 7.4 release, we have included a Moderation System for Questions App, integrated with Liferay's Workflow Framework.\n\nIt is an approval workflow for message boards based on reputation. Enabling it, the messages and replies posted by a user will be evaluated by a moderator to check they fulfill the rules of conduct, quality, or conditions that the site's administrators have agreed before they are published.\n\nWhen the user has contributed properly with a configured number of messages, the new posts will be automatically approved.\n\nUsage\n-----\n\n### Admins\n\nThe Moderation System can be configured through **System Settings → Message Boards → Message Boards Moderation Workflow**\n\nOn the configuration page, you can enable and disable the moderation system and establish the minimum number of contributed messages to publish the user's messages directly without being reviewed by a moderator.\n\nThe moderation system is incompatible with other workflow definitions for message boards**.**\n\n### Users\n\nFrom the user's perspective, the user has clear information about the Questions App moderation process.\n\nWhen a user with no minimum reputation creates a question, the submit question's label indicates that the question is being submitted for publication and should be reviewed:\n\nThen, he can see the question labeled as Pending\n\nIf the user has enough reputation the submit question's label indicates that the question is posted directly:\n\nConclusion\n----------\n\nThe Moderation System allows you to add Q&A pages to your sites and have a simple but powerful system to control the user's interactions out of the box, which is a very important feature of this kind of application.", "Javier de Arcos", "2021-07-15");