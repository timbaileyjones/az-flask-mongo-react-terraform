# tamino-web-app

This repository contains the web app application known as Tamino

## Major componenents

tamino-web-app contains the following items:
  * a React web application built with [Material UI](https://material-ui.com) that handles these topic areas:
    * Recipe Management 
      * Recipe Steps (including Mixing, High Heat, Low Heat, Depowdering, 3-D printing, various measurement steps)
    * Order Entry and Submission
  * a Python/flask webapp application that handles the database requirements of the React web application.
  * CloudFormation templates that define many other resources related to the Tamino manufacturing platform, including:
    *  Storage  
       * a KMS-encrypted S3 bucket to store raw data coming from devices in the manufacturing labs
       * 5 DynamoDB tables
          - orders-${Environment}
          - recipes-${Environment}
          - recipeSteps-${Environment}
          - mix-materials-inventory-${Environment}
          - mix-devices-${Environment}
    * Compute Infrastructure
      * ECS cluster/service with Fargatetask to run the Python/flask application
      * Lambda functions
        - [Process Orders](./lambda/orders.py)
      * Greengrass Lambda functions
        - [Passthrough](lambda/orders-ggc.py)
    * IoT Core Rules Engine
      - Tamino_Materials_Inventory_Rule (**Inventory**)
        - `SELECT * FROM 'data/qa/amrdc_pb1/inventory/gateway001/controller_inv/#'`
        - Inventory_TPC Controller (Labview runtime w/ AWS IoT SDK)
        - Sends payload which gets stored in `mix-materials-inventory-${Environment}`
      - Tamino_Mix_Devices_Rule (**Mixing**)
        - `SELECT * FROM 'data/qa/amrdc_pb1/mixing/gateway001/controller_mix/#'`
        - Mixing_Controller Controller (Labview runtime w/ AWS IoT SDK)
        - Sends payload which gets stored in `mix-devices-${Environment}`
      - Tamino_Mix_Devices_Rule (**Mixing**)
        - `SELECT * FROM 'data/qa/amrdc_pb1/inventory/gateway001/controller_inv/materials_pulled'`
        - Inventory_TPC Controller (Labview runtime w/ AWS IoT SDK)
        - Triggers Lambda Function [Process Orders](./lambda/orders.py)
    * Other infrastructure
      * An application load balancer (ALB) to connect users to the web application tasks running in Fargate.
      * a short DNS name in Route53 for accessing the web application 
      * execution roles for all of the above
      * CloudWatch log group for the python/flask web-application
      * IAM roles to support the above functionality
    * Other Documentation
      * [Inventory and Mixing Payloads](./docs/documented_payloads.md)
      * Greengrass Subscriptions (*[Passthrough](lambda/orders-ggc.py) currently used to handle JSON Dict serialization*) 

          | Source | Target | Topic |
          |---|---|---|
          | Controller | passthrough_ggc | data/${Building}/amrdc_pb1/# |
          | passthrough_ggc | IoT Cloud | data/${Building}/amrdc_pb1/# |
          | IoT Cloud | passthrough_ggc | cmd/${Building}/amrdc_pb1/# |
          | passthrough_ggc | Controller | cmd/${Building}/amrdc_pb1/# |

This repository does NOT contain the CI/CD pipeline that auto-builds and auto-deploys this app.  For that, refer to the  [recipe-editor pipeline in the aws-cross-accounts-pipeline repo](https://github.mmm.com/CRL/aws-cross-account-pipelines/blob/master/templates/recipe-editor/pipeline.yaml#L184)


## Getting Started

This application was bootstrapped with [CreateReactApp], so there's a ton of great [information here](docs/CREATE_REACT_APP.md) about getting started with this repository.

### Requirements

 - Docker
 - [focker](https://github.mmm.com/blackbird/docker-aws-azure-login)
 - python
 - [Material-UI](https://material-ui.com)
 - [DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GettingStarted.html)

Before starting login to the qa account with focker_

Once you familiarize yourself with the structure of the application and how this all fits together with React you can spin up a development environment in docker with:

```
make develop
```

This command will:

 - build a docker image with flask and yarn available
 - launch a container
   - mount your working directory inside
   - install node modules
   - launch flask/react in dev (hot reload) modes
 - output logs to /var/log
 - open a shell into the running container

View the running app at [http://localhost:3000](http://localhost:3000)

The first run will install all the node modules required. This take a long time. Subsequent runs still take a while but are much faster to run. The react dev server is resource intensive. The entrypoint for the container will output any logs from the server after it runs. 

> A timeout of ~60 seconds is set on the entrypoint.

### Developer Notes: 

Python/flask web backend
 * The python/flask application resides at `app` in this repository.
 * The REST handlers are in `app/rest`.
 * The unit tests for the backend are in `app/tests`.
 * Several potentially-helpful handlers for debugging are in `app/main.py`.  They are
   * `http://<host:port>/getenv` - shows the container's environment as JSON
   * `http://<host:port>/headers` - shows the request's headers as JSON.  This can be used to determine the headers that the ALB is passing to the application.

CloudFormation resources:
  * The tamino-ecs-environment.yaml is in `deployment`.

Lambda resources:
  * The lambda for the order event is in `lambda`.

React application:
  * The react application is under `src`. 
  * The react application uses [Material UI](https://material-ui.com) library, resulting in more appealing, standardized and functional UI than without using a pre-canned set of visual elements.
    * An outstanding set of video tutorials on using React with Material is available at [CodeRealm's youtube channel](https://www.youtube.com/channel/UCUDLFXXKG6zSA1d746rbzLQ}).
  *  The left-hand menu implementation is at `src/Menu/left-menu.js`
  * The <App> component has several utility methods that are passed as props to every child/descendant component. They are:
    * [transient notifications]( https://iamhosseindhv.com/notistack#material-props) (known as "snacks", )
      * `this.props.postDefaultSnack(message)`
      * `this.props.postErrorSnack(message)`
      * `this.props.postSuccessSnack(message)`
      * `this.props.postWarningSnack(message)`
      * `this.props.postSnack(message, options)`
    * global error reporting facility (dismissable dialog)
      * `reportError(error)`
    * `refreshRecipes()` - load all recipes into a global cache
    * `refreshRecipeSteps()` - same, but for recipe steps
    * `refreshOrders()` - same, but for orders
  * There is also a global search window at the top of the screen. It controls the `searchText` property,
    which is also propogated throughout the app.  It is used mostly by the <LeftMenu> widget to filter the
    visible recipes, steps and orders.
  *  The "hamburger menu" and its slideout drawer are at `src/componenents/Layout/index.js`
  * Each topic area of the app is available at subdirectories under `src/components`.  
    * Orders -  `src/components/Orders`
    * Recipes -  `src/components/Recipes`
    * RecipeSteps -  `src/components/RecipeSteps`
  * Each of these above directories contains, at minimum, a component for rendering the items as a list, and another componenet for editing just one of those items.
  * The `src/components/RecipeSteps` directory has a bit more to it.  
    * There are a few JSON-only files under   `src/components/RecipeSteps/data`.  They are:
      * gritTypes.js / fritTypes.js
      * process-steps.js / units-of-measure.js
        * The metadata about the values to be input and displayed for each of NINE distinct process types are in this file.

  * There is a generic step editor at recipe-step-form.js.  It uses the data from process-steps.js to generate data entry screens for each of the nine process types.  
  * For the Mixing step, the data entry requirements are much more involved.  For this reason, the form at `src/components/RecipeSteps/recipe-mixing-step-form.js` is used instead of the generic step editor.  
  * It is expected that, as this project evolves, some of the other step types may require more than what the generic step editor can offer, and will require custom form editors similar to the one for Mixing.
  * The specific requirements the Mixing step requires that made the generic step editor inappropriate were:
    * A complex formula involving material density constants, and mix ratios to compute a `targetMixDensity`.
    * A pair of percentage fields that must always equal 100%.
    *  Dropdown menus offering a choice of material types (grit/abrasive and frit/bond).


