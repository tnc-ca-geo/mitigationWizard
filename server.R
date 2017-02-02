library(leaflet)
library(foreign)
#library(geojsonio)
#hex <- readLines("c:/users/cschloss/documents/mitWiz/hex_al_cc_gp_sp_wgs84_geojson.json") #%>% paste(collapse = "\n")
#file_to_geojson("n:/sf_bay_area/projects/ramp/mitWiz/sample.shp", method='local', output='c:/users/cschloss/documents/mitWiz/sample4')


# Pathways
#--------------------------
setwd("./")


options(stringsAsFactors = F)
#key<-read.csv("c:/users/cschloss/documents/mitWiz/key.csv", as.is=T)
key<-read.csv("key.csv", as.is=T)
keyVec<-as.data.frame(t(key))
names(keyVec)<-as.character(keyVec['Name',])
keyVec<-keyVec['Code',]

#lineDBF<-read.dbf("N:\\SF_Bay_Area\\Projects\\RAMP\\mitWiz\\fake_road_pop.dbf", as.is=T)
#line <- geojson_read("c:/users/cschloss/documents/mitWiz/fakeroad.geojson")
lineDBF<-read.dbf("fake_road_pop.dbf", as.is=T)
line <- geojson_read("fakeroad.geojson")
hex2 <- geojson_read("sample4.geojson")

shinyServer(function(input, output, session) {
  observeEvent(input$Map_geojson_click, { # update the map markers and view on map clicks
    click <- input$Map_geojson_click
    p<-click$properties$Project
    #print(p)
    sub<-lineDBF[which(lineDBF$Project==p),]
    #print(sub)
    kc<-key$Code[key$Code%in%names(lineDBF)]
    sub<-(sub[,kc])
    subsum<-apply(sub, 2, sum)
    keyList<-as.list(keyVec[keyVec%in%names(subsum)[which(subsum>0)]])
    output$text1<-renderText({paste('Project Name:', click$properties$Project)})
    updateCheckboxGroupInput(session, "checkSpecies",
                              choices = keyList,
                               selected = keyList)
  })


    
  species<-reactive({as.character(input$checkSpecies)})
    
  output$Map <- renderLeaflet({
    leaflet() %>% setView(lng = -122.21, lat = 37.95, zoom = 10)  %>% addTiles() %>%
      addGeoJSON(line)
  })
  

  consPriori<-reactive({(input$consPriori)})
  
  distPA<-reactive({(input$distPA)})  
  pNat<-reactive({(input$pNat)})  
  
 
 
  # score_nor <- sapply(hex2$features, function(feat) {
  #   feat$properties$score_nor})
  # 

  #pal <- colorQuantile("Greens", score_nor)
 
 observeEvent(input$checkSpecies, {
 output$hexmap <- renderLeaflet({
  if(length(species())==0){
   leaflet()  %>% setView(lng = -122.21, lat = 37.95, zoom = 12) %>% addTiles()}
   if(length(species())!=0){
   score_col <- sapply(hex2$features, function(feat, cp) {
    feat$properties[cp]}, consPriori())
   if(consPriori()!="score_nor"&consPriori()!="CLN_num"&consPriori()!="groundw"){pal <- colorBin("Greens", unlist(score_col), 2)}
   if(consPriori()=="CLN_num"){pal <- colorBin("Greens", unlist(score_col), 4)}
   if(consPriori()=="score_nor"|consPriori()=="groundw"){pal <- colorQuantile("Greens", unlist(score_col))}
   
   
   # Gather GDP estimate from all countries
   natDat <- sapply(hex2$features, function(feat) {
     feat$properties$pNat
   })
   # Gather population estimate from all countries
   dpDat <- sapply(hex2$features, function(feat) {
     feat$properties$distPA
   })
   
   outCol1<-rep(1,length(dpDat))
   outCol1[which(natDat>=pNat()&dpDat<=distPA())]<-2
   pal2<-colorNumeric(c('#ffffff'),  c(1))
   if(pNat()>0|distPA()<10){pal2<-colorNumeric(c('#ffffff','#FFCC00'), c(1,2))}
  
                                           
   
   #pal2<-colorBin(c('#ffffff', '#ffffff', '#FFCC00'), domain=natDat, bins=c(0, 101, 200))
   #if(pNat()!=0){pal2<-colorBin(c('#ffffff', '#ffffff', '#FFCC00'), domain=natDat, bins=c(0, pNat(), 101))}
   
   #pal2<-colorBin(c("Greens"), dpDat, c(0,pNat))
   #color=pal2(feat$properties[['pNat']])

   
   hex2$features <- lapply(hex2$features, function(feat) {
       feat$properties$outline<- list(rep(1, length(feat$properties$pNat)))
       if(unlist(feat$properties$pNat)>=pNat()&unlist(feat$properties$distPA<=distPA())){
         feat$properties$outline<- 2}
         feat
         })
           #feat$properties$gdp_md_est / max(1, feat$properties$pop_est)
       
  hex2$features <- lapply(hex2$features, function(feat, species, cp) {
     if(min(unlist(feat$properties[species]))==0){
       feat$properties$style <- list(
         fillColor = pal(feat$properties[[cp]]),
         weight=0, color='#ffffff', fillOpacity=0, opacity=0)
     }
     if(min(unlist(feat$properties[species]))!=0){
       feat$properties$style <- list(
         fillColor = pal(feat$properties[[cp]]),
         weight=1, color=pal2(as.numeric(feat$properties$outline)), fillOpacity=.8)
       #print(outCol2)
     }
  
  
     feat
   }, species=species(), cp=consPriori())
   leaflet()  %>% setView(lng = -122.21, lat = 37.95, zoom = 12) %>% addTiles()   %>% 
   addGeoJSON(hex2)
   }
 })
 
 })
 })


