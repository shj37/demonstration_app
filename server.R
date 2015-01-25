library(shiny)
library(MASS)
library(datasets); data(mtcars)

options(digits=4)

mtcars$am <- as.factor(mtcars$am)
levels(mtcars$am) <- c("Automatic", "Manual")
mtcars$cyl <- as.factor(mtcars$cyl)
mtcars$vs <- as.factor(mtcars$vs)

#simple regression
fit <- lm(mpg~am, data = mtcars)

#best multiple without interaction
fitall<-lm(mpg~.,data=mtcars)
bestfit <- stepAIC(fitall, direction="both",trace=FALSE)


#best multiple with interaction
fit_cross<-lm(mpg~wt^2+wt*am+qsec*am,data=mtcars)
bestfit_cross <- stepAIC(fit_cross, direction="both",trace=FALSE)

shinyServer(function(input, output) {
      #step 1  
      output$structure <- renderPrint({
            str(mtcars)
      })
      
      output$head_six <- renderPrint({
            head(mtcars)
      })
      
      output$summary1 <- renderPrint({
            summary(mtcars)
      })
      
      
      #step 2
      output$summary2 <- renderPrint({
            rbind(c("Automatic:",summary(mtcars[mtcars$am=="Automatic","mpg"])), 
                  c("Manual:",summary(mtcars[mtcars$am=="Manual","mpg"])))
      })
      
      output$boxplot2 <- renderPlot({
            boxplot(mpg~am, data = mtcars,
                    col = c("blue", "green"),
                    xlab = "Transmission",
                    ylab = "Miles per Gallon",
                    main = "MPG by Transmission Type")
      })
      
      output$hist2 <- renderPlot({
            par(mfrow = c(1, 2))
            # Histogram with Normal Curve
            x_auto <- mtcars[mtcars$am=="Automatic","mpg"]
            
            h1<-hist(x_auto, xlim=c(10,35),breaks=8, col="red", xlab="Miles Per Gallon",
                    main="Miles Per Gallon for Automatic")
            h1
            xfit_auto<-seq(min(x_auto),max(x_auto),length=40)
            yfit_auto<-dnorm(xfit_auto,mean=mean(x_auto),sd=sd(x_auto))
            yfit_auto<-yfit_auto*diff(h1$mids[1:2])*length(x_auto)
            lines(xfit_auto, yfit_auto, col="blue", lwd=2)
            
            x_manu <- mtcars[mtcars$am=="Manual","mpg"]
            h2<-hist(x_manu, xlim=c(10,35), breaks=8, col="red", xlab="Miles Per Gallon",
                    main="Miles Per Gallon for Manual")
            h2
            xfit_manu<-seq(min(x_manu),max(x_manu),length=40)
            yfit_manu<-dnorm(xfit_manu,mean=mean(x_manu),sd=sd(x_manu))
            yfit_manu<-yfit_manu*diff(h2$mids[1:2])*length(x_manu)
            lines(xfit_manu, yfit_manu, col="blue", lwd=2)
            par(mfrow = c(1, 1))
      })
      
      #step 3
      output$normality3 <- renderPrint({
            rbind(c("shapiro.test P-value for MPG(Automatic):", 
                    shapiro.test(mtcars[mtcars$am=="Automatic","mpg"])$p.value), 
                  c("shapiro.test P-value for MPG(Manual):",
                    shapiro.test(mtcars[mtcars$am=="Manual","mpg"])$p.value))
      })
      
      output$equality3 <- renderPrint({
            c("Fisher's F-test P-value:", var.test(mtcars[mtcars$am=="Automatic","mpg"],
                                                   mtcars[mtcars$am=="Manual","mpg"])$p.value)
      })
      
      output$hypothesis3 <- renderPrint({
            c("T-test P-value:", t.test(mtcars[mtcars$am=="Manual","mpg"],
                                                 mtcars[mtcars$am=="Automatic","mpg"], 
                                                 alternative = "greater",
                                                 var.equal=FALSE, paired=FALSE)$p.value)
      })
      
      #step 4
      output$simple4 <- renderPrint({
            
            summary(fit)
      })
      
      output$multi_without4 <- renderPrint({

            summary(bestfit)
      })
      
      output$multi_with4 <- renderPrint({

            summary(bestfit_cross)
      })
      
      #step 5
      output$anova5 <- renderPrint({
            anova(fit, bestfit,bestfit_cross)
      })
      
      
      #step 6
      output$residuals6 <- renderPlot({
            layout(matrix(c(1,2,3,4),2,2))
            plot(bestfit_cross)
      })
})
