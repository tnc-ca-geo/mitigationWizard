library(raster)
library(shiny)
library(shinydashboard)
library(leaflet)
library(geojsonio)


# Pathways
#--------------------------
setwd("./")



options(stringsAsFactors = F)
#key<-read.csv("c:/users/cschloss/documents/mitWiz/key.csv", as.is=T)
key<-read.csv("key.csv", as.is=T)
keyVec<-as.data.frame(t(key))
names(keyVec)<-as.character(keyVec['Name',])
keyVec<-keyVec['Code',]
keyList1<-as.list(keyVec)

keyCP<-read.csv("keyCP.csv", as.is=T)
keyCPVec<-as.data.frame(t(keyCP))
names(keyCPVec)<-as.character(keyCPVec['Name',])
keyCPVec<-keyCPVec['Code',]
keyCPList1<-as.list(keyCPVec)


#shinyUI(pageWithSidebar(
shinyUI(dashboardPage( skin="green",
    dashboardHeader(title="Mitigation Wizard"),
    dashboardSidebar(disable=TRUE),
    dashboardBody(
                  fluidRow(
                    column(4,
                    box(width=20,  background="black", height='4.3in',
                           
                          h5('Choose a transportation project'),
                          h6('Click on a project on the map below to identify species with potential mitigation needs for that project'),
                          h6('This is optional.  You may also select species for mitigation using the checkboxes to the right'),
                          textOutput('text1'),
                          leafletOutput("Map", height="2.3in")
                    )),
                    column(4, 
                    box(width=20, background="black", height='4.3in',
                    #h2("Select Species that you need to mitigate for"),
                    checkboxGroupInput("checkSpecies", label = h5("Choose mitigation species"), 
                                       choices = keyList1,
                                       selected = "")
                    )),
                    column(4, 
                    box(width=20, background="black", 
                           
                    # selectInput("consPriori", label=h5("Choose Conservation Priorities"), 
                    #             choices=list("Heat Map of Conservation Priorities"='score_nor', 
                    #                          "Bay Area Critical Linkages" = 'BACLlink_g',
                    #                          "Conservation Lands Network" = 'CLN_num',
                    #                          "TNC ECoregional Priorities" = 'TNC_gp',
                    #                          "Protected Lands"='cons_fee'
                    #                          ),
                    #             selected='score_nor'),
                    
                    
                    selectInput("consPriori", label=h5("Choose conservation priorities"), 
                                       choices = keyCPList1,
                                       selected = 'score_nor'),
                    
                    p()
                  ),
                  
                  box(width=20,background="black",
                  
                  h5('Other mitigation criteria'),
                  
                  selectInput("dist", label=h5("Proximity to Impact"), 
                              choices=list("No Restriction", 
                                           "Same HUC12 Watershed", 
                                           "Same HUC10 Watershed",
                                           "Same Service Area",
                                           "Same County")
                              ),
                  sliderInput("distPA", label=h5("Sites are within X miles of protected land:"), 
                              min=0, max=10, value=10),
                  
                  # Decimal interval with step value
                  sliderInput("pNat", label=h5("Sites are at least X % natural lands"), 
                              min = 0, max = 100, value = 0)
                                  
                  )
                  
                  
                  
                  
                  ),
                  leafletOutput("hexmap"))
                    
                    #leafletOutput("combMap"),
                    #plotOutput("weightChart")
    )                
))



