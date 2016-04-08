library(shiny)


# Define UI for application that draws a histogram
shinyUI(navbarPage("Projet Enjeu INC 09",
  
  # Application title
  tabPanel("Accueil",fluidPage(
      img(src = "CentraleSupelec.png", height = 100, align = "left"),
      img(src = "IBM.png", height = 100, align = "right"),
      p(height = 100),
      h1("Livrable", align = 'center'),
      h3("Projet Enjeu INC 09", align = 'center')),
      p(height = 100),
      h4("Présentation"),
      p("Ce livrable est un scénario de démonstration s'appuyant sur un jeu de données issue l’Université de DoMinho au Portugal et visant à implémenter différents modèles statistiques de données.
      Ce jeu de données s’inscrit dans le contexte d’une campagne marketing d’une banque portugaise. 
      Celle-ci avait pour objectif d’appeler un client pour lui proposer et lui faire souscrire à un
      prêt bancaire. Durant un appel de cette campagne, 16 caractéristiques du client appelé ont été 
      sauvegardées dans cette base de donnée. Ces attributs sont présentés dans l'onglet descriptif. 
      De plus, à la fin de chaque appel, le résultat de la proposition a été enregistrée. Ainsi, 
      l’objectif de ce scénario de démonstration est d’implémenter des modèles statistiques sur ce 
      jeu de données pour pouvoir ultérieurement, à partir des caractéristiques d’un client potentiel, 
      déterminer s’il est utile pour la banque d’appeler ce client ou non. Ce scénario de démonstration 
      rentre ainsi dans la problématique CRM au niveau de l’identification des segments de clientèle. 
      Intégré lors d’une future campagne, il permettra à la banque de ne pas perdre de temps à appeler 
      des clients qui de toute façon n’ont aucun intérêt à souscrire ce prêt."),
      h4("Jeu de données"),
      p("Ce jeu de données est disponible ici et a été publié par"),
      a("[Moro et al., 2011] S. Moro, R. Laureano and P. Cortez. Using Data Mining for Bank Direct Marketing: An Application of the CRISP-DM Methodology. 
  In P. Novais et al. (Eds.), Proceedings of the European Simulation and Modelling Conference - ESM'2011, pp. 117-121, Guimarães, Portugal, October, 2011. EUROSIS.", href = "S. Moro, R. Laureano and P. Cortez. Using Data Mining for Bank …", align = "center")),
  tabPanel("Partie descriptive",
      h1("Description du jeu de données"),
      
      h4("Les informations personnelles du client"),
      p("— Age : l’âge du client"),
      p("— Job : la catégorie socio-professionnelle : « admin. », « unknown », « unemployed », «
      management », « housemaid », « entrepreneur », « student », « blue-collar », « self-employed
      », « retired », « technician », « services »"),
      p("— Marital : statut marital du client : « married », « divorced », « single »"),
      p("— Education : « unknown », « secondary », « primary », « tertiary »"),
      h4("Les informations bancaires du client"),
      p("— Default: le crédit est-il en défaut : « yes », « no »"),
      p("— Balance : solde moyen du client à la fin de l’année"),
      p("— Housing : le client possède-t-il un prêt immobilier ? : « yes », « no » — Loan : le client possède-t-il un prêt : « yes », « no »"),
      h4("Les informations de contact"),
      p("Contact : type de communication utilisé : « unknown », « telephone », « cellular » — Day : dernier jour de contact : numéro du jour"),
      p("— Month: dernier mois de contact: « jan », « feb », « mar », ..., « dec »"),
      p("— Duration : durée du contact"),
      p("— Campaign : nombre de contact réalisés dans cette campagne"),
      h4("Les informations concernant les campagnes précédentes"),
      p("— Pdays : Nombre de jours depuis la dernière campagne"),
      p("— Previous : Nombre de contacts réalisés lors de la dernière campagne"),
      p("— Poutcome : issue de la campagne précédente : « unknown », « « failure », « success »"),
      h4("Résultat"),
      p("— Y : Le client a-t-il souscrit au produit bancaire : « yes », « no »")),
  tabPanel("Partie Prédictive",
      h1("Prédiction de la variable y"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins",
                  "Nombre d'intervalles sur l'histogramme:",
                  min = 5,
                  max = 50,
                  value = 30),
      sliderInput("TrainSize",label = "Taille de l'echantillon d'apprentissage",
                  min = 10000, max = 44000, value = 40000), 
      sliderInput("Poids", label = "Poids appliqué aux faux positifs : plus le poids est élevé, moins les faux positifs seront importants", min = 0.1, max = 0.9, value = 0.58),
      h3("Prédiction du résultat de la campagne marketing pour un client dont les caractéristiques sont :"),
      h4("Caractéristiques personnelles"),
      sliderInput("age","âge",value = 30,min = 18, max = 100),
      selectInput("job","métier",choices=list("admin.","blue-collar","unemployed","management","housemaid","entrepreneur","student","self-employed","retired","technician","services","unknown")),
      selectInput("marital","statut marital", choices = list("married","divorced","single")),
      selectInput("education","niveau d'éducation", choices = list("secondary","primary","tertiary","unknown")),
      radioButtons("default","situation de faillite", choices = list("yes","no")),
      sliderInput("balance","moyenne annuelle du solde du compte", value= 1360, min = -8000, max = 100000),
      radioButtons("housing","possède un crédit immobilier", choices = list("yes","no")),
      radioButtons("loan","possède un autre type de crédit", choices = list("yes","no")),
      h4("Durant la campagne marketing en cours"),
      selectInput("contact","dernier moyen de contact", choices = list("telephone","cellular","unknown")),
      sliderInput("day","jour du contact précédent", value = 15,min = 1, max = 31),
      selectInput("month","mois du contact précédent", choices = list("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec")),
      sliderInput("duration","durée de l'appel précédent en secondes",value = 260, min = 0, max = 5000),
      h4("Données sur la campagne marketting précédente"),
      sliderInput("campaign","nombre de contact total pendant la totalité de la campagne",value = 3,min = 1, max = 70),
      sliderInput("pdays","nombre de jours écoulés depuis le dernier contact de la campagne précédente", value = 40, min = -1, max = 900),
      sliderInput("previous","nombre de contact durant la campagne précédente",value = 1, min = 0, max = 300),
      radioButtons("poutcome","résultat de la dernière campagne", choices = list("failure","success","other","unknown"))
      
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
     
      h3("Histogramme"),
      plotOutput("distPlot"),
      h3('Résumé des modèles'),
      p("Graphique supperposant les courbes ROC obtenues avec les différents modèles présentés ci-dessous"),
      plotOutput('ROC'),
      h3("Arbre de décision"),
      p("Une version simplifiée de l'arbre est représentée ci-dessus."),
      plotOutput("Tree"),
      p("La matrice de confusion obtenue avec l'arbre de décision est"),
      tableOutput("TreeMatrix"),
      h3("Régression logistique"),
      tableOutput("LGMatrix"),
      h3("Classification naïve bayésienne"),
      tableOutput("NBMatrix"),
      h3("Reseau neuronal"),
      plotOutput("neuralnetwork"),
      h3("Prédiction"),
      tableOutput("PredictionArbre")
     ###### 
    )
  ))
))