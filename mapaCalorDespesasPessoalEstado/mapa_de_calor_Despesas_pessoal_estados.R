
listaSiglasUF <- function(){
  UFs<-c("AC","AL","AM","AP","BA","CE","DF","ES","GO","MA","MG","MS","MT","PA","PE","PB","PI","PR","RJ","RN","RO","RR","RS","SC","SE","SP","TO")
  UFs
  
}


adicionaBaseEstados <- function(tipo_lancamento){ #1- Caixa, 2-Competência
  library(readxl)
  library(tidyr)
  
  if (tipo_lancamento ==1){
    arquivo<-"series_mensal_GFSM.xls"
  } else{
    arquivo<-"series_mensal_GFSM-competencia.xls"
  }
  
  UFs<- listaSiglasUF()
  serie_analise <-data.frame("UF"= character(),"Rubrica"=character(), "Data"=character(), "Valor"=numeric() )
  
  
  
  
  for (UF in UFs){
    serie<-read.xlsx(arquivo,sheetName = UF, rowIndex = c(1,17,18,23,26,27))
    serie$UF <- UF
    names(serie)[1]<-"Rubrica"
    serie_analise <- rbind(serie_analise,gather(serie,Data,Valor,-Rubrica,-UF))
    serie_analise$Data <- gsub("X","",serie_analise$Data)
    serie_analise$Data <- gsub("[.]","-",serie_analise$Data)
    
  }
  
  serie_analise

}




trataSelecaoUsuario <- function(df_series_trabalho, dt_ini, dt_fim, denominador, tipo_despesa, nivel_critico){
  
  df_series_trabalho <- df_series_trabalho[df_series_trabalho$Data>=dt_ini & df_series_trabalho$Data<=dt_fim,] 
  
  if (denominador==1){
    df_serie_total_denominador <- df_series_trabalho[df_series_trabalho$Rubrica %in% c("Total-Receitas"),]
    
  } else{
    df_serie_total_denominador <- df_series_trabalho[df_series_trabalho$Rubrica %in% c("Total-Despesas"),]
    
  }
  
  if (tipo_despesa == 1){ #Despesas de pessoal total
    df_series_trabalho <- df_series_trabalho[df_series_trabalho$Rubrica %in% c("211-REMUNERACAO DE EMPREGADOS - SALARIOS E VENCIMENTOS","212-REMUNERACAO DE EMPREGADOS - CONTRIBUICOES SOCIAIS","273-BENEFICIOS SOCIAIS - BENEFICIOS SOCIAIS DO EMPREGADOR"),]
    
  } else if (tipo_despesa ==2){ #despesas de pessoal ativo
    df_series_trabalho <- df_series_trabalho[df_series_trabalho$Rubrica %in% c("211-REMUNERACAO DE EMPREGADOS - SALARIOS E VENCIMENTOS","212-REMUNERACAO DE EMPREGADOS - CONTRIBUICOES SOCIAIS"),]
    
  }else if (tipo_despesa ==3){ #despesas de pessoal inativo
    df_series_trabalho <- df_series_trabalho[df_series_trabalho$Rubrica %in% c("273-BENEFICIOS SOCIAIS - BENEFICIOS SOCIAIS DO EMPREGADOR"),]
    
  }
  
  df_series_trabalho <- aggregate(df_series_trabalho$Valor, by = list(UF=df_series_trabalho$UF,Data=df_series_trabalho$Data),sum)
  df_series_trabalho <- merge(df_series_trabalho,df_serie_total_denominador, by.x= c("UF","Data"), by.y=c("UF","Data"))
  df_series_trabalho$Proporcao_Despesa <- df_series_trabalho$x/df_series_trabalho$Valor 
  UF <- with(df_series_trabalho[,], reorder(UF,Proporcao_Despesa,median)) #df_series_trabalho$Data == max(df_series_trabalho$Data)
  df_series_trabalho$UF<-factor(df_series_trabalho$UF, levels = levels(UF))
  
  
  
  graph<-ggplot(df_series_trabalho, aes(df_series_trabalho$Data,df_series_trabalho$UF)) +
    geom_tile(aes(fill = Proporcao_Despesa*100), color = "white") +
    scale_fill_gradient2(low = "steelblue", high = "red", midpoint = nivel_critico) +
    ylab("UFs ") +
    xlab("Data") +
    theme(legend.title = element_text(size = 10),
          legend.text = element_text(size = 12),
          plot.title = element_text(size=16),
          axis.title=element_text(size=14,face="bold"),
          axis.text.x = element_text(angle = 90, hjust = 1, size=8)) +
    labs(fill = "(%)")
  
  return(graph)


}



