# Mon Jan  8 22:28:12 2018 ------------------------------
#Aula 3
library(tidyverse)
library(datasets)
library(broom)

#Summarize & group_by com 
data(iris)
head(iris)

iris %>%
       group_by(Species) %>%
       summarise(média = mean(Petal.Length))

iris %>% 
       filter(Species != "versicolor") %>% 
       group_by(Species) %>% 
       summarise_all(mean)

mtcars %>% 
       arrange(cyl, desc(mpg), desc(hp)) %>% 
       select(cyl, mpg, hp)

#dplyr e broom

dados<-read.table("Rafael_bovo_dados2.txt", h=TRUE)
dim(dados)#dimensões da tabela
head(dados);str(dados)

df_lm <- dados %>%
       filter(Species == "Physalaemus_cuvieri") %>%
       nest_by(Mountain_Range) %>%
       mutate(mod = list(lm(CTMin_cloacal~Altitude,data = data)))

df_lm %>%
       reframe(broom::tidy(mod))

df_lm %>%
       summarise(broom::glance(mod))

df_lm2 <- dados %>%
       nest_by(Mountain_Range, Species) %>%
       mutate(mod2 = list(lm(CTMin_cloacal~Altitude,data = data)))

df_lm2 %>%
       reframe(broom::tidy(mod2))

df_lm2 %>%
       summarise(broom::glance(mod2))

#---Desafio
#Fazer uma regressão entre component e time para cada 'type' e 'group'

vddata2 <- read.csv("diogo_week.csv", header=T)
head(vddata2)
str(vddata2)

