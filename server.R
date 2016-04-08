library(shiny)
library(rpart)
library(rpart.plot)
library(gmodels)
library(reshape)
library("neuralnet")
library(ROCR)
library(e1071)
#setwd("/srv/shiny-server/App1")
source("nnet.R")


df2 = read.table("Data Set.csv",header=TRUE,sep=";")
colnames(df2) <- c("Age","Job","Marital","Education","Default","Balance","Housing","Loan","Contact","Day","Month","Duration","Campaign","Pdays","Previous","Poutcome","Result")

df = read.table("bank-full2.csv",header=TRUE,sep=";")

#Arbres de decision C5.0
#/!\ Les librairies suivantes ne sont pas install??es par d??faut, mais R les installe normalement seul
#Sinon, utiliser RStudio qui permet d'installer facilement de nouvelles librairies

df$result<-as.factor(df$result)

#On cr??e le germe 123, qui permet de toujours obtenir les m??mes r??sultats al??atoires
set.seed(123)



# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  output$distPlot <- renderPlot({
    age    <- df[, 1]  # Old Faithful Geyser data
    bins <- seq(min(age), max(age), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(age, breaks = bins, col = 'skyblue', border = 'white',main="Histogramme de l'age des personnes participant a l'etude",freq=FALSE,xlab="Age",ylab="Frequence")
  })
  f1 <- reactive({
    train_sample <- sample(45211,input$TrainSize)
    train_sample
  })
  
  DfTrain <- reactive({
    train_sample <- f1()
    df_train<-df[train_sample,]
  })
  
  DfTest <- reactive({
    train_sample <- f1()
    df_test<-df[-train_sample,]
  })
  
  Arbre <- reactive({
    df_train = DfTrain()
    df_test = DfTest()
    arbre <- rpart(df_train$result~., data = df_train, parms = list(split = "information",prior = c(input$Poids,1-input$Poids)), control = rpart.control(minsplit = 2,maxdepth = 12,cp = 0))
    arbreSimplifie <- prune(arbre,cp = arbre$cptable[which.min(arbre$cptable[,4]),1])
  })
  
  ReseauNeuronal <- reactive({
    neuralnet(Result~Age+Job+Marital+Education+Default+Balance+Housing+Loan+Contact+Day+Month+Duration+Campaign+Pdays+Previous+Poutcome, df2, hidden=c(3,2), threshold = 0.8, linear.output=T)
  })
  
  LG <- reactive({
    df_train = DfTrain()
    df_test = DfTest()
    lgmodel=glm(df_train$result~., data=df_train, family= binomial())
  })
  
  NB <- reactive({
    df_train = DfTrain()
    df_test = DfTest()
    donnees = naiveBayes(result~., df_train)
    donnees
  })
  
  Donnees <- reactive({
    client <- c(as.integer(as.character(input$age)),input$job,input$marital,input$education,input$default,
                as.integer(input$balance),input$housing,input$loan,input$contact,as.integer(input$day),input$month,
                as.integer(input$duration),as.integer(input$campaign),as.integer(input$pdays),as.integer(input$previous),input$poutcome)
    client <- as.data.frame(t(client))
    colnames(client) <- c("age","job","marital","education","default","balance","housing","loan","contact","day","month","duration","campaign","pdays","previous","poutcome")
    client$age <- as.integer(as.character(client$age))
    client$balance <- as.integer(as.character(client$balance))
    client$day <- as.integer(as.character(client$day))
    client$duration <- as.integer(as.character(client$duration))
    client$campaign <- as.integer(as.character(client$campaign))
    client$pdays <- as.integer(as.character(client$pdays))
    client$previous <- as.integer(as.character(client$previous))
    is.integer(client$age)
    print(client)
  })
  
  output$text1 <- renderText({
    paste("La taille de l'echantillon de travail est de",input$TrainSize," lignes. Celle de l'echantillon de test est de",45211-input$TrainSize,'.')
  })
  
  output$ROC <- renderPlot({
    arbre = Arbre()
    df_test = DfTest()
    df_train = DfTrain()
    predTree <- predict(arbre,df_test,type="prob")
    predROC <- ROCR::prediction(predTree[,2],df_test$result)
    plot(performance(predROC,"tpr","fpr"), col = "red", xlab = "Taux de faux positifs", ylab = "Taux de vrais positif")
    abline(0, 1, lty = 2)
    
    lgmodel <- LG()
    predLG <- predict(lgmodel,newdata=df_test, type="response")
    predict <- ROCR::prediction(predLG, df_test$result)
    perf <- performance(predict, measure = "tpr", x.measure = "fpr")
    plot(perf, add = TRUE, col = "blue")
    
    donnees <- NB()
    predNB=predict(donnees, df_test, type ="raw")
    predROC <- ROCR::prediction(predNB[,2],df_test$result)
    plot(performance(predROC,"tpr","fpr"), col = "green", add= T)
    
    #nn <- ReseauNeuronal()
    #df2 <- df_test$result
    #df2[df2 = "no"] = 0
    #df2[df2 = "yes"] = 1
    #prednn <- neuralnet::compute(nn,df2)
    #head(prednn)
    #predROC <- ROCR::prediction(prednn,df_test$result)
    #plot(performance(predROC,"tpr","fpr"), col = "black", add= T)
    
    legend(0.7,0.4,col = c("red","blue","green"),legend = c('Arbre de décision','Régression logistique','Classification bayésienne'),cex = 1,lty = 1)
    
  })
  
  output$Tree <- renderPlot({
    arbre = Arbre()
    arbre <- prune(arbre, cp = 1e-02)
    rpart.plot(arbre,extra = 1)
  })
  output$TreeMatrix <- renderTable({
    arbre = Arbre()
    df_test = DfTest()
    prediction <- predict(arbre,df_test,type=c("vector"))
    resultat = CrossTable(df_test$result, prediction, prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE,dnn = c('actual result', 'predicted result'))
    tableau <- resultat$prop.row
    colnames(tableau) <- c("L'arbre predit NON","L'arbre predit OUI")
    rownames(tableau) <- c("Le resultat etait NON","Le resultat etait OUI")
    tableau
  })
  
  output$LGMatrix <- renderTable({
    lgmodel = LG()
    df_test <- DfTest()
    pred <- predict(lgmodel,newdata=df_test, type="response")
    alpha=0.5
    pred[pred>alpha] <- 1
    pred[pred<alpha] <- 0
    resultat = CrossTable(df_test$result, pred, prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE,dnn = c('actual result', 'predicted result'))
    tableau <- resultat$prop.row
    colnames(tableau) <- c("Le modèle predit NON","Le modèle predit OUI")
    rownames(tableau) <- c("Le resultat etait NON","Le resultat etait OUI")
    tableau
  })
  
  output$NBMatrix <- renderTable({
    modele <- NB()
    df_test <- DfTest()
    prediction <- predict(modele, df_test)
    resultat <- CrossTable(df_test$result, prediction, prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE,dnn = c('actual result', 'predicted result'))
    tableau <- resultat$prop.row
    colnames(tableau) <- c("Le modèle predit NON","Le modèle predit OUI")
    rownames(tableau) <- c("Le resultat etait NON","Le resultat etait OUI")
    tableau
    
  })
  
  output$neuralnetwork <- renderPlot({
    plot.nnet(ReseauNeuronal())
    
  #Prédiction
  output$PredictionArbre <- renderTable({
    client = Donnees()
    arbre = Arbre()
    prediction <- predict(arbre,client)
    rownames(prediction) <- c("Arbre de décision")
    colnames(prediction) <- c("non","oui")
    prediction
  })
  })
})