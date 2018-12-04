library(tidyverse)
library(readxl)
library(DescTools)

## funcao para calcular as proporcoes de uma linha ou coluna

prop <- function(x){return(x/sum(x))}
prop2 <- function(tabela, l, c){return(sum(tabela[l,])*sum(tabela[,c])/(sum(tabela)^2))}

### 1

## Vamos realizar um teste de aderencia para verificar se o numero de acidentes em
## cada dia da semana muda ou nao.

# H0: p1 = p2 = p3 = ... = p7 VS H1: pelo menos um deles diferente dos demais

## Analise descritiva

Dia <- c("Seg", "Ter", "Qua", "Qui", "Sex", "Sab", "Dom")
Numeros <- c(20,10,10,15,30,20,35)

base1 <- tibble(Dia, Numeros)

# sob H0, como pi = pj, para i,j = {1,2,...,7}, pi = 1/7
base1 %>% mutate(`Frequencia Esperada` = (1/7)*sum(Numeros))

# Observando a tabela, vemos que alguns valores estao longe da frequencia esperada,
# o que pode ser indicativo de que os dias da semana interferem no numero de acidentes

# como as frequencias sao todas maiores que cinco, podemos realizar o teste de
# aderencia sem problemas

chisq.test(Numeros, p = rep(1/7, 7), correct = F)

# Adotando um nivel de significancia de 1%, rejeitamos H0, pois obtivemos p-valor
# muito menor. Ou seja, temos evidencias de que o numero de acidentes muda de 
# acordo com o dia da semana.


### 2

## Queremos verificar a relacao entre o tipo de cancer com a reacao a quimioterapia

## Pela forma como foram coletadas as amostras, vamos realizar um teste de homoge-
## neidade, para verificar sua relacao

## Vamos comparar como um paciente de um tipo reage a quimioterapia

# H0: p11 = p21 = p31 = p41, ... , p13 = p23 = p33 = p43 VS
# H1: pelo menos uma delas diferentes

## Analise descritiva

tabela2 <- matrix(c(51,58,48,26,33,29,42,38,16,13,30,16), nrow = 4, ncol = 3)
colnames(tabela2) <- c('Pouca','Media','Alta')
(rownames(tabela2) <- c("tipo 1", "tipo 2", "tipo 3", "tipo 4"))

## Tabela com as proporcoes 

## funcao para calcular as proporcoes de uma linha ou coluna

prop <- function(x){return(x/sum(x))}

(tabela.prop <- apply(tabela2, 1, prop))

barplot(tabela.prop, col = c(2,7,4))

# Pelo que vemos na tabela e no grafico, as proporcoes das pessoas com o cancer do
# tipo 4 sao diferentes das demais

chisq.test(tabela2, correct = F)
 
# Adotando um nivel de significancia de 1%, rejeitamos H0, pois obtivemos p-valor
# menor. Ou seja, temos evidencias de que o tipo de cancer afeta a reacao a
# quimioterapia

### 3
base3 <- read_excel("Banco Escalas Psicologia.xls", na = "999")
base3 <- base3[-(215:219),] # retirando as ultimas linhas
base3$Grupo <- ordered(base3$Grupo, labels = c("controle","Trauma","TEPT"))
base3$Sexo <- factor(base3$Sexo, labels = c("M","F"))

## (a)

# Vamos realizar um teste de hipotese para media

## Analise descritiva

base3 %>% group_by(Grupo) %>% 
  summarise(media = mean(Idade, na.rm = T), sd = sd(Idade, na.rm = T))

ggplot(base3, aes(x = Grupo)) + geom_boxplot(aes(y = Idade), fill = c(3,4,5))

## Pelo que podemos observar na tabela e no boxplot, as medias parecem proximas

## Teste ANOVA

## Vamos supor independencia
## Vamos verificar normalidade

ggplot(base3, aes(sample = Idade)) + stat_qq() + stat_qq_line() + facet_wrap(~Grupo)

# Parece ser razoavel supor normalidade para os 3 grupos

# teste

aux = base3$Idade[base3$Grupo=="controle"]
ks.test(aux, "pnorm", mean(aux, na.rm=T), sd(aux, na.rm=T))
aux = base3$Idade[base3$Grupo=="Trauma"]
ks.test(aux, "pnorm", mean(aux, na.rm=T), sd(aux, na.rm=T))
aux = base3$Idade[base3$Grupo=="TEPT"]
ks.test(aux, "pnorm", mean(aux, na.rm=T), sd(aux, na.rm=T))

## Adotando um nivel de significancia de 3%, nao rejeitamos nenhuma das hipoteses
## nulas, portanto, e razoavel supor normalidade para  idade de cada grupo

## Testando variancias iguais

LeveneTest(base3$Idade, base3$Grupo, center = "mean")

## Adotando um nivel de significancia de 3%, nao rejeitamos H0, entao considerare
## mos as variancias iguais.

## Teste ANOVA

teste3a <- aov(Idade~Grupo, data = base3)
summary(teste3a)

## Adotando um nivel de significancia de 3%, rejeitamos H0, ou seja, ha
## evidencias de que pelo menos uma das medias sao diferentes

PostHocTest(teste3a, method = "bonferroni")

## Entramos em contradicao, pois concluimos que as medias comparadas 2 a 2 sao
## todas iguais

## (b)

## Pela forma de coleta, vamos fazer um teste de independencia

# H0: genero e transtorno sao independentes (Pij = Pi.*P.j) vs 
# H1: genero e transtorno nao sao independentes

## Analise descritiva

## tabela com as frequencias

base3 %>% group_by(Sexo, Grupo) %>% filter(Grupo != "controle") %>%
  summarise(freq = n())
(tabela <- matrix(c(23, 26, 50, 57), nrow = 2, ncol = 2))

## tabela com as proporcoes observadas e proporcoes esperadas, sob H0 verdadeiro

base3 %>% group_by(Sexo, Grupo) %>% filter(Grupo != "controle") %>%
  summarise(prop = n()/sum(tabela))
tabela3$prop.esp= c(prop2(tabela,1,1),prop2(tabela,2,1),prop2(tabela,1,2),
                    prop2(tabela, 2,2))

tabela3

## Comparando as proporcoes esperadas e observadas, parece bastante razoavel supor que 
## elas sao independentes

## teste chi-quadrada (Independencia)


chisq.test(tabela, correct = F)

## Adotando um nivel de significancia de 5%, nao rejeitamos H0, entao considerare
## que as variaveis genero e transtorno sao independentes

## (c)

## Precisamos fazer ANOVA 

# Verificando normalidade

ggplot(base3, aes(sample = Anos_escolaridade)) + stat_qq() + stat_qq_line() +
  facet_wrap(~Grupo)

base3$Anos_escolaridade[base3$Grupo=="controle"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T) ,sd(.,na.rm=T),alternative = "two.sided")
base3$Anos_escolaridade[base3$Grupo=="Trauma"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T) ,sd(.,na.rm=T),alternative = "two.sided")
base3$Anos_escolaridade[base3$Grupo=="TEPT"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T),sd(.,na.rm=T),alternative = "two.sided")

# Adotando um nivel de significancia de 5%, rejeitamos H0, ou seja, rejeitamos
# a hipotese de que as variaveis sao provenientes de uma distribuicao normal,
# portanto nao podemos realizar ANOVA.

## (d)

## Precisamos fazer ANOVA 

## Vamos supor independencia

## Verificando normalidade

ggplot(base3, aes(sample = QI)) + stat_qq() + stat_qq_line() + facet_wrap(~Grupo)

## Observando o grafico, os dados parecem seguir uma distribuicao normal

base3$QI[base3$Grupo=="controle"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T) ,sd(.,na.rm=T),alternative = "two.sided")
base3$QI[base3$Grupo=="Trauma"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T) ,sd(.,na.rm=T),alternative = "two.sided")
base3$QI[base3$Grupo=="TEPT"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T),sd(.,na.rm=T),alternative = "two.sided")

# Adotando um nivel de significancia de 5%, nao rejeitamos H0, ou seja, e razoa-
# vel suporque as variaveis sao provenientes de uma distribuicao normal

## Testando homocedasticidade (variancias iguais)

LeveneTest(base3$QI, base3$Grupo, center = "mean")

## Adotando um nivel de significancia de 5%, nao rejeitamos H0, entao considerare
## mos as variancias iguais.

teste3d = aov(QI~Grupo, data =base3)
summary(teste3d)

# Adotando um nivel de significancia de 5%, rejeitamos H0, ou seja, ha pelo menos
# um par de medias diferente

PostHocTest(teste3d, method = "bonferroni")

# Adotando nivel de significancia 1.66% (correcao), concluimos que a media do
# QI do grupo TEPT e diferente do grupo que nao tem nenhum transtorno, as outras
# sao iguais

## (e)

## Precisamos fazer ANOVA para as 5 variaveis

## Vamos supor independencia de todas elas

## Verificando normalidade de cada variavel

ggplot(base3, aes(sample = RAVLT)) + stat_qq() + stat_qq_line() + facet_wrap(~Grupo)
ggplot(base3, aes(sample = WCST)) + stat_qq() + stat_qq_line() + facet_wrap(~Grupo)
ggplot(base3, aes(sample = Stroop)) + stat_qq() + stat_qq_line() + facet_wrap(~Grupo)
ggplot(base3, aes(sample = Digitos)) + stat_qq() + stat_qq_line() + facet_wrap(~Grupo)
ggplot(base3, aes(sample = `Reprodu�ao Visual`)) + stat_qq() + stat_qq_line() + facet_wrap(~Grupo)

## RAVLT , WCST e reproducao visual parecem estar proximos de uma normal, Stroop e digitos
## nem tanto, mas vamos fazer teste de normalidade para verificar mais precisamente

## Para RAVLT
base3$RAVLT[base3$Grupo=="controle"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T) ,sd(.,na.rm=T),alternative = "two.sided")
base3$RAVLT[base3$Grupo=="Trauma"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T) ,sd(.,na.rm=T),alternative = "two.sided")
base3$RAVLT[base3$Grupo=="TEPT"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T),sd(.,na.rm=T),alternative = "two.sided")

# Adotando nivel de significancia de 3%, nao rejeitamos H0 em nenhum dos tres casos, assim
# consideraremos normalidade para os dados de RAVLT para cada grupo

## Para WCST
base3$WCST[base3$Grupo=="controle"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T) ,sd(.,na.rm=T),alternative = "two.sided")
base3$WCST[base3$Grupo=="Trauma"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T) ,sd(.,na.rm=T),alternative = "two.sided")
base3$WCST[base3$Grupo=="TEPT"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T),sd(.,na.rm=T),alternative = "two.sided")

# Adotando nivel de significancia de 3%, rejeitamos H0 para o grupo controle, assim nao
# podemos realizar ANOVA para essa variavel, mesmo que as outras sejam normais

## Para Stroop
base3$Stroop[base3$Grupo=="controle"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T) ,sd(.,na.rm=T),alternative = "two.sided")
base3$Stroop[base3$Grupo=="Trauma"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T) ,sd(.,na.rm=T),alternative = "two.sided")
base3$Stroop[base3$Grupo=="TEPT"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T),sd(.,na.rm=T),alternative = "two.sided")

# Adotando nivel de significancia de 3%, nao rejeitamos H0 em nenhum dos tres casos, assim
# consideraremos normalidade para os dados de Stroop para cada grupo

## Para Digitos
base3$Digitos[base3$Grupo=="controle"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T) ,sd(.,na.rm=T),alternative = "two.sided")
base3$Digitos[base3$Grupo=="Trauma"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T) ,sd(.,na.rm=T),alternative = "two.sided")
base3$Digitos[base3$Grupo=="TEPT"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T),sd(.,na.rm=T),alternative = "two.sided")

# Adotando nivel de significancia de 3%, nao rejeitamos H0 em nenhum dos tres casos, assim
# consideraremos normalidade para os dados de Digitos para cada grupo

## Para Reproducao visual
base3$`Reprodu�ao Visual`[base3$Grupo=="controle"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T) ,sd(.,na.rm=T),alternative = "two.sided")
base3$`Reprodu�ao Visual`[base3$Grupo=="Trauma"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T) ,sd(.,na.rm=T),alternative = "two.sided")
base3$`Reprodu�ao Visual`[base3$Grupo=="TEPT"] %>%
  ks.test(.,"pnorm",mean(.,na.rm=T),sd(.,na.rm=T),alternative = "two.sided")

# Adotando nivel de significancia de 3%, nao rejeitamos H0 em nenhum dos tres casos, assim
# consideraremos normalidade para os dados de reproducao visual para cada grupo

# Agora, vamos testar se as variancias sao iguais para RAVLT, Stroop, Digitos e reproducao 
# visual

LeveneTest(base3$RAVLT, base3$Grupo, center = "mean")
LeveneTest(base3$Stroop, base3$Grupo, center = "mean")
LeveneTest(base3$Digitos, base3$Grupo, center = "mean")
LeveneTest(base3$`Reprodu�ao Visual`, base3$Grupo, center = "mean")

# Adotando nivel de significancia igual a 3%, rejeitamos H0 para Stroop e Digitos, ou seja
# ha evidencias de que as variancias dessas variaveis nao sao iguais quando divididas em
# relacao a grupo. Por outro lado, nao rejeitamos H0 para RAVLT e reproducao visual, 
# assim, consideraremos que suas variancias sao iguais, portanto podemos fazer ANOVA para
# estas duas variaveis.

## ANOVA

teste3e <- aov(RAVLT~Grupo, data = base3)
teste3e2 <- aov(`Reprodu�ao Visual`~Grupo, data = base3)
summary(teste3e)
summary(teste3e2)

# Adotando nivel de significancia igual a 3%, rejeitamos H0 para os dois testes, ou seja
# temos evidencias de que ha pelo menos um par de medias diferentes em cada uma das varia
# veis

## Vamos verificar quais medias sao diferentes

PostHocTest(teste3e, method = "bonferroni")

# Para RAVLT, adotando nivel de significancia de 1% (correcao), concluimos que somente
# TEPT e trauma possuem medias iguais

PostHocTest(teste3e2, method = "bonferroni")

# Para reproducao visual, nao rejeitamos H0 em nenhum caso, ou seja, o teste indica que 
# as medias sao iguais, entrando em cotradicao com o teste ANOVA

### 4