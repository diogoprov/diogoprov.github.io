#Crescimento Logístico
###############################
dn.dt=function(r,N,K){(r*N*(1-N/K))}
taxa<-dn.dt(r=1,N=0:120, K=100)
plot(0:120, taxa, type="l", ylab="dn/dt", xlab="N")
abline(h=0)
## adicionando pontos com legendas
Np<-c(0,10, 50,100,110)
dn.p<-dn.dt(r=1,N=Np, K=100)
points(Np,dn.p ,cex=1.6)
text(Np, dn.p, letters[1:5], adj=c(0.5,2))
## direção de mudança no N
arrows(20,2,80,2,length=0.1,lwd=3)
arrows(122,-2, 109,-2, length=0.1, lwd=3)

cresc.log=function(N0=10, r=0.05, K=80, tseq=1:100)
{
	resulta=K/(1+((K-N0)/N0)*exp(-r*tseq))
	return(resulta)
}

cresc.log(N0=1, r=0.1, K=100, tseq=1:100)
pop1<-cresc.log(N0=1, r=0.1, K=100, tseq=1:100)
plot(1:100, pop1,type="l", xlab="tempo", ylab="N")
title(sub="N0 =1; r=0.1; K=100")

##################################
### o efeito do tamanho inicial ##
##################################
N0.seq=c(1,(1:12)*10)
tmax=100
res.mat=matrix(NA, ncol=length(N0.seq),nrow=tmax+1)
for(i in 1:length(N0.seq))
{
	res.mat[,i]<-cresc.log(N0=N0.seq[i],r=0.1,K=100,tseq=0:tmax)
}

matplot(0:100,res.mat,type="l", col=rainbow(length(N0.seq)), lty=1:13)

#####################################
### O Efeito da Capacidade Suporte ##
#####################################
K.seq=(1:12)*10
tmax=100
resK.mat=matrix(NA, ncol=length(K.seq),nrow=tmax+1)
for(i in 1:length(K.seq))
{
	resK.mat[,i]<-cresc.log(N0=1,r=0.1,K=K.seq[i],tseq=0:tmax)
}

matplot(0:100,resK.mat,type="l", col=rainbow(length(N0.seq)), lty=1:13)
text(rep(90, length(K.seq)),K.seq+2, labels=paste("K =",K.seq),cex=0.8)

#Integração Numérica do Crescimento Logístico
# função de crescimento logístico 
clogistico<-function(tempo, y, parms)
{
	n<-y[1]
	r<-parms[1]
	K<-parms[2]
	dN.dt<-r* n* (1- n/K)
	return(list(c(dN.dt)))
}

parametros=c(r=1,K=100)
N0= 1
st=seq(0.1,10, by=0.1)

library(deSolve)
res<-ode(y=N0, times=st, clogistico, parms=parametros)
str(res)
head(res)

plot(res[,1], res[,2], main="Crescimento Logístico", type="l", xlab="Tempo", ylab="N", col="red" )
legend("topleft", "N0=1;r = 1; K = 100", bty="n")

#Estocasticidade Ambiental
clogEst <- function(times,y, parms)
{
	n<-y[1]
	r<-parms[1]
	K<-rnorm(1,mean=parms[2],sd=sqrt(parms[3]))
	dN.dt<-r* n* (1- n/K)
	return(list(c(dN.dt))) 
} 
y0 = c(10)
prmt=c(r=0.15, K=30, varK=20)
st=seq(0,100,by=0.01)
res.clogEst= ode(y=y0,times=st, func=clogEst,parms=prmt)
plot(res.clogEst[,1], res.clogEst[,2], type="l", col="red",lwd=2, xlab="tempo", ylab="y")

#Crescimento Logístico com Retardo
require(PBSddesolve)
clogDelay <- function(t,N,parms) 
{
	if (t < parms[3])
		lag <- parms[4]
	else
		lag <- pastvalue(t - parms[3])
	
	n<-lag
	r<-parms[1]
	K<-parms[2]
	dN.dt<-r* n* (1- n/K)
	return(list(c(dN.dt)))
}

#defina os valores da iniciais da população e os parâmetros
N0= 10
parametros=c(r=3.7,K=100, retardo=0.5, initial=N0)

# solucione a derivação numérica com retardo
pop <- dde(y=N0,times=seq(0,100,0.1),func=clogDelay ,parms=parametros)
# veja a estrutura do objeto que guardou os resultados
str(pop)
# faça um gráfico
plot(pop$t, pop$y1, type="l", col="red", xlab="tempo", ylab="Numero de indivíduos", main="Crescimento Logistico com retardo")

############################
### Crescimento Discreto ###
############################

discrLog=function(N0=1, rd=0.05, K=100, tmax=100)
{
	resulta=rep(N0,tmax)
	for(t in 2:tmax)
	{
		lastN=resulta[t-1]
		resulta[t]=lastN+rd*lastN*(1-lastN/K)
	}
	return(resulta)
}

pop2<-discrLog(N0=1, rd=0.05, K=100, tmax=100)
plot(1:100,pop2, pch=16, col="red",xlab="tempo (gerações)", ylab="Tamanho da população (N)", bty="l", cex.lab=1.2, cex.axis=1.2)	
lines(1:100, pop2, lty=2, cex=0.8)

#Bifurcação do Atrator
N0=10 
K=100
tmax=200
nrd=10
rd.s=seq(1,3,length=nrd)
rd.s
r1=sapply(rd.s, function(x){discrLog(N0=N0, rd=x, K=K,tmax=tmax)})
str(r1) ## veja a estrutura do arquivo;
r2=stack(as.data.frame(r1))
str(r2) ## veja como mudou!cada indice é relacionado à coluna antiga
names(r2)=c("N", "old.col")
r2$rd=rep(rd.s,each=tmax)
r2$tempo=rep(1:tmax, nrd)
res.bif=subset(r2, tempo>0.5*tmax) ## pegando apenas o tempos maiores onde a população já deve ter convergido
plot(N~rd, data=res.bif, pch=".", cex=2)


cLVcomp=function(t,n,prts)
{
	with(as.list(prts),{
		dn1.dt= r1*n[1]*((k1-n[1]-alfa*n[2])/k1)
		dn2.dt= r2*n[2]*((k2-n[2]-beta*n[1])/k2)
		list(c(dn1.dt,dn2.dt))
	})  
}
#Agora vamos estabelecer parâmetros e condição inicial para rodar o modelo e produzir o gráfico:
library(deSolve)
prmts<-c(r1=0.05,r2=0.03,k1=80,k2=50,alfa=4, beta=0.5)
N0<-c(10,10)
res=ode(y=N0, times=seq(1,100,0.01), func=cLVcomp, parms=prmts)
matplot(res[,1],res[,-1], type="l", ylab="Número de indivíduos", xlab="tempo", main="Modelo de Competição Lotka-Volterra")
#Vamos agora aumentar o tempo de simulação:
res=ode(y=N0, times=seq(1,200,0.01), func=cLVcomp, parms=prmts)
matplot(res[,1],res[,-1], type="l", ylab="Número de indivíduos", xlab="tempo", main="Modelo de Competição Lotka-Volterra")
