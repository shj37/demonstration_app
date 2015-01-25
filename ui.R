library(shiny)
library(MASS)
library(datasets); data(mtcars)

options(digits=4)

mtcars$am <- as.factor(mtcars$am)
levels(mtcars$am) <- c("Automatic", "Manual")
mtcars$cyl <- as.factor(mtcars$cyl)
mtcars$vs <- as.factor(mtcars$vs)

shinyUI(fluidPage(
    
  # Application title
  titlePanel("Analysis of Fuel Efficiency and Transmission"),
  
  navlistPanel(
        "Statistical Analysis", 
        tabPanel("Step 1: Data Inspection", 
                 h3("Data Inspection"),
                 "Check data structure and first six observations. We are mainly interested in the relationship 
                 between miles per gallon and transmission types",
                 tabsetPanel(type = "tabs",
                       tabPanel("Data Structure", verbatimTextOutput("structure")),
                       tabPanel("First Six Observations", verbatimTextOutput("head_six")),
                       tabPanel("Summary", verbatimTextOutput("summary1"))
                     
                 )
        ),
        tabPanel("Step 2: Compare MPG", 
                 h3("Compare Miles Per Gallon for Automatic and Manual Transmission"),
                 "Check MPG distribution for each type of transmission",
                 tabsetPanel(type = "tabs",
                       tabPanel("Summary", verbatimTextOutput("summary2")),
                       tabPanel("Boxplot", plotOutput("boxplot2")),
                       tabPanel("Histogram", plotOutput("hist2"))
                       
                 )
        ),
        tabPanel("Step 3: Test MPG(Auto) < MPG(Manu)",
                 h3("T-test for MPG(Auto) < MPG(Manu)"),
                 h4("Test assumptions for T-test"),
                 "Normality: MPG(automatic) ~ Normal,  MPG(manual) ~ Normal",
                 verbatimTextOutput("normality3"),
                 
                 "Equal variance assumption for T-test: Variance(MPG(automatic)) = Variance(MPG(manual))",
                 verbatimTextOutput("equality3"),
                
                 "Thus we cannot reject that both are normally distributed, 
                    but they may have different variance.",
                 
                 br(),
                 
                 h4("One-sided independent 2-group t-testT-test with unequal variance"),
                 "Null Hypothesis: MPG(Auto) > MPG(Manu)",
                 verbatimTextOutput("hypothesis3"),
                 
                 "Thus cars with manual transmission are more fuel efficient than cars with automatic transmission.
                    "
                 
        ),
        tabPanel("Step 4: Quantify MPG Difference",
                 h3("Quantify MPG Difference between Automatic and Manual Transmission Cars"),
                 "Compare simple regression model, multivariate regression model without interactions,
                 and multivariate regression model with interactions",
                 tabsetPanel(type = "tabs",
                             tabPanel("Simple Regression", verbatimTextOutput("simple4"),
                                      "The simple regression model can only explain 36% variation in miles per gallon."),
                             tabPanel("Multivariate without Interactions", "We perform the stepwise selection 
                                      using the stepAIC( ) function from the MASS package for R.", 
                                      verbatimTextOutput("multi_without4"),
                                      "The optimal model derived from the algorithm includes the transmission type 
                                      compounded with the weight of the car (wt) and 1/4 mile time (qsec). 
                                      It explains 85% of variation in miles per gallon and on average manual transmission 
                                      tends to increase 2.93 miles per gallon.)"),
                             tabPanel("Multivariate with Interactions", 
                                      "Transmission type may also affect the marginal impact of car weight (wt) 
                                      and 1/4 mile time (qsec). Thus I add interactions am-by-qsec and am-by-wt 
                                      to refine our analysis. I also add weight-squared to control for potential variance 
                                      in the impact of car weight. Again we apply the stepwise selection using the stepAIC( ) function 
                                      from the MASS package for R.",
                                      verbatimTextOutput("multi_with4"),
                                      "The result shows that adding interactions significantly improve model performance, 
                                      i.e. transmission type also affect marginal impact of car weight. 
                                      On average, the manual transmission improves fuel efficiency from two sources: 
                                      it increases 14.08 miles per gallon with 95% confidence interval (7.03, 21.13), 
                                      and it reduces the impact of car weight on fuel consumption at 4.14 miles per gallon 
                                      for every 1000lb. The model also explains 90% variation in miles per gallon.")
                             
                 )
                 
        ),
        tabPanel("Step 5: Compare Three Models", 
                 h3("Analysis of Variance"),
                 verbatimTextOutput("anova5"),
                 "Not surprisingly, the multivariate regression model with interactions is the best among the three. 
                 However, we may be able to continue improving the model by combining existing variables to 
                 create better predictors while maintaining sufficient degree of freedom."
                 
        ),
        tabPanel("Step 6: Regression Diagnostics", 
                 plotOutput("residuals6"),
                 "The points in the Residuals vs Fitted plot are randomly scattered without any special pattern.",
                 "Normal Q-Q plot shows that residuals are normal distributed though there are some deviation at both tails.",
                 "Scale-Location plot shows relatively constant variance among residuals at different levels, 
                 thus no significant heteroskedacity.",
                 "Residuals vs Leverage plot shows that there are three potential outliers though their impacts are limited."
                 
        )
  
  )
  
))
