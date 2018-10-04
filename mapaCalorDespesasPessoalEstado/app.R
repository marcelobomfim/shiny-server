#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(lubridate)
library(future)
library(plotly)



#path<-paste0(getwd(),"/mapaCalorDespesasPessoalEstado/","mapa_de_calor_Despesas_pessoal_estados.R")
source("mapa_de_calor_Despesas_pessoal_estados.R")
#source(path)

serie_caixa_analise <- adicionaBaseEstados(1)
serie_competencia_analise<-adicionaBaseEstados(2)


  


# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Mapa de Calor de Despesas de Pessoal"),


  
  
  sidebarLayout(
    sidebarPanel(
      dateRangeInput("data",
                  "Data",
                  min = as.Date(min(serie_caixa_analise$Data)),
                  max = as.Date(max(serie_caixa_analise$Data)),
                  start = as.Date(max(serie_caixa_analise$Data))- years(2),
                  end = as.Date(max(serie_caixa_analise$Data)),
                  language = "pt-BR",
                  startview ="year",
                  format="dd/mm/yyyy",
                  separator = "até"
      ),
      
      
      radioButtons("tipoLancamento",
                   "Tipo Lancamento",
                   choices = c("Caixa"="1",
                               "Competência"="2")),
      radioButtons("tipoDespesa",
                   "Tipo de Despesa",
                   choices = c("Pessoal Total"="1",
                               "Pessoal Ativo"="2",
                               "Pessoal Inativo"="3")),
      

      radioButtons("denominador",
                   "Denominador",
                   choices = c("Receita Total"="1",
                               "Despesa Total"="2")),
      
      
      sliderInput("nivelCritico",
                  "Nível Crítico (%)",
                  min = 0,
                  max = 100,
                  value = 0,
                  sep =".",
                  ticks = TRUE
      )
      
    ),
    
    mainPanel(
      plotlyOutput("mapaCalorEstados",height = 700)
      
    )

    
  )
  
  
)

server <- function(input, output, session) {
  
#  if (interactive()){
    myReactives <- reactiveValues(reactInd = 0)
    
    observe({
      input$tipoLancamento
      myReactives$reactInd <- 1
    })
    
    observe({
      input$data
      myReactives$reactInd <- 2
    })
    
    observe({
      input$denominador
      myReactives$reactInd <- 3
    })
    
    observe({
      input$tipoDespesa
      myReactives$reactInd <- 4
    })
    
    observe({
      input$nivelCritico
      myReactives$reactInd <- 5
    })
    
 # }

  
   output$mapaCalorEstados <- renderPlotly({
     
     
     if (input$tipoLancamento=="1"){
       df_series_trabalho<-serie_caixa_analise
     } else{
       df_series_trabalho<-serie_competencia_analise
     }
     
     graph<-trataSelecaoUsuario(df_series_trabalho,
                         input$data[1],
                         input$data[2],
                         input$denominador,
                         input$tipoDespesa,
                         input$nivelCritico)
     
     
     if (myReactives$reactInd!=5|input$nivelCritico==0){
       updateSliderInput(session, "nivelCritico",
                         min = round(min(graph$data$Proporcao_Despesa)*100),
                         max = round(max(graph$data$Proporcao_Despesa)*100),
                         step = 1,
                         value = median(graph$data$Proporcao_Despesa)*100)
        


     }
     
     
     ggplotly(graph)
     
     
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

