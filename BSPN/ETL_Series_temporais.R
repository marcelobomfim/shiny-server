library(readxl)
library(tidyr)

BP_ts_Uniao <- read_excel("BSPN.xlsx",
                       sheet = "BP União")
BP_ts_Uniao$esfera <- "UNIAO"

BP_ts_Estados <- read_excel("BSPN.xlsx",
                          sheet = "BP Estados")
BP_ts_Estados$esfera <- "ESTADOS"

BP_ts_Municipios <- read_excel("BSPN.xlsx",
                            sheet = "BP Municípios")
BP_ts_Municipios$esfera <- "MUNICIPIOS" 

DVP_ts_Uniao <- read_excel("BSPN.xlsx",
                           sheet = "DVP União")
DVP_ts_Uniao$esfera<- "UNIAO"

DVP_ts_Estados <- read_excel("BSPN.xlsx",
                             sheet = "DVP Estados")
DVP_ts_Estados$esfera <-"ESTADOS"

DVP_ts_Municipios <- read_excel("BSPN.xlsx",
                                sheet = "DVP Municípios")
DVP_ts_Municipios$esfera <- "MUNICIPIOS"

BSPN_ts <- rbind(BP_ts_Uniao, BP_ts_Estados,BP_ts_Municipios, DVP_ts_Uniao, DVP_ts_Estados, DVP_ts_Municipios)

BSPN_ts <- gather(BSPN_ts, key = "ano",value="valor", c(2:6))

BSPN_ts$valor <-as.numeric(BSPN_ts$valor)

BSPN_ts$codigo <- substr(BSPN_ts$Conta,1,15)

BSPN_ts <-BSPN_ts[!(BSPN_ts$Conta%in%c("2.1.0.0.0.00.00 - Passivo Circulante - Financeiro","2.2.0.0.0.00.00 - Passivo Não Circulante - Financeiro")),]

save(list=c("BSPN_ts"),file="BSPN_ts.Rdata")
