#-------------SCE-UA  GR4J-------------------
library(rtop)
GR4J <- function(P,E,k1,k2,x1,x2,x3,x4) {
  # x1 = 350  #产流水库容量，mm
  # x2 = 0   #地下水交换系数，mm
  # x3 = 90   #汇流水库容量，mm
  # x4 = 1.7  #单位线汇流时间，d
  # k1 = 0.5
  # k2 = 0.5
  # dat = read.table("I:/新安江模型编写/样例数据/日模样例.csv",header = T,sep = ",")
  # P = dat[,5]
  # E = dat[,6]
  Pn = NULL  #有效降水，mm
  Ps = NULL  #补充产流水库的降水量
  Pr = NULL  #总的产流量，mm
  En = NULL  #剩余蒸发能力，mm
  Es = NULL  #产流水库蒸散发量，mm
  Qr = NULL  #汇流水库出流量
  Qd = NULL  #与地下水交汇量汇合后的出流量
  Q = NULL   #流域总出流,mm
  
  S = k1*x1   #初值  小于等于x1
  R = k2*x3   #初值  小于等于x3
  for (i in 1:length(P)) {
    if (P[i] >= E[i]) {
      Pn[i] = P[i] - E[i]
      En[i] = 0
      Ps[i] = x1*(1-(S/x1)^2)*tanh(Pn[i]/x1) / (1+S/x1+tanh(Pn[i]/x1))
      Es[i] = 0
    } 
    else { 
      En[i] = E[i] - P[i]
      Pn[i] = 0
      Es[i] = S*(2-S/x1)*tanh(En[i]/x1) / (1+(1-S/x1)*tanh(En[i]/x1))
      Ps[i] = 0
    }
    S = S-Es[i] + Ps[i]
    Perc = S*(1-(1+(4*S/(9*x1))^4)^(-1/4))
    S = S-Perc
    Pr[i] = Perc+Pn[i]- Ps[i]
  }
  UH1 = uh1(x4)
  UH2 = uh2(x4)
  n1 = length(UH1)
  n2 = length(UH2)
  Q9 = NULL
  Q1 = NULL
  for (i in 1:length(Pr)) {
    Q9[i] = 0
    Q1[i] = 0
    if (i >= n2) {
      for (k in 1:n1) {
        Q9[i] = Q9[i] + UH1[k]*Pr[i+1-k]*0.9
      }
      for (k in 1:n2) {
        Q1[i] = Q1[i] + UH2[k]*Pr[i+1-k]*0.1
      }
    } else if (i >= n1 & i < n2 ) {
      for (k in 1:n1) {
        Q9[i] = Q9[i] + UH1[k]*Pr[i+1-k]*0.9
      }
      for (k in 1:i) {
        Q1[i] = Q1[i] + UH2[k]*Pr[i+1-k]*0.1
      }
    } else if (i < n1) {
      for (k in 1:i) {
        Q9[i] = Q9[i] + UH1[k]*Pr[i+1-k]*0.9
      }
      for (k in 1:i) {
        Q1[i] = Q1[i] + UH2[k]*Pr[i+1-k]*0.1
      }
    }
    FF = x2*(R/x3)^(7/2)
    R = max(c(0,(Q9[i] + FF +R)))
    Qr[i] = R*(1-(1+(R/x3)^4)^(-1/4))
    R = R-Qr[i]
    Qd[i] = max(c(0,(Q1[i] + FF)))
    Q[i] = Qr[i] + Qd[i]
    
  }
  
  RUNOFF = Q
  out = data.frame(P,E,Pr,RUNOFF) #,ET,EXC,INF,REC,GW,SMS
  return(out)
}

uh1 <- function(x4) {
  if (x4 <= 1) {
    u = 1
  } else {
    x = ceiling(x4)
    S = NULL
    for (t in 1:x) {
      if (t < x4) {
        S[t] = (t/x4)^(5/2)
      } else {
        S[t] = 1
      }
    }
    u = NULL
    u[1] = S[1]
    for (i in 2:x) {
      u[i] = S[i]-S[i-1]
    }
  }
  
  return(u)
}

uh2 <- function(x4) {
  u = NULL
  if (x4 <= 0.5) {
    u = 1
  } else if (x4 > 0.5 & x4 < 1) {
    u[1] = 1-0.5*(2-1/x4)^(2.5)
    u[2] = 1-u[1]
  } else if (x4 == 1) {
    u[1] = 0.5*(1/x4)^2.5
    u[2] = 1-u[1]
  } else if (x4 > 1) {
    x = ceiling(x4)
    S = NULL
    for (i in 1:(2*x)) {
      if (i <= x4) {S[i] = 0.5*(i/x4)^2.5}
      else if (i>x4 & i < 2*x4) {S[i] = 1-0.5*(2-i/x4)^2.5}
      else {S[i] = 1}
    }
    u[1] = S[1]
    for (j in 2:(2*x)) {
      u[j] = S[j]-S[j-1]
    }
  }
  return(u)
}
dat = read.table("/池潭2014-2016-daily-PEQ.csv",header = T,sep = ",")
P = dat[,5]
E = dat[,6]
Q = dat[,7]
Validinput_P <<- P
Validinput_E <<- E
Validinput_Q <<- Q
Validinput_DAREA <<- 4766

fit = function(x) {
  x1 = x[1]; x2 = x[2];
  x3 = x[3]; x4 = x[4]
  P = Validinput_P
  E = Validinput_E
  Rre = Validinput_Q*24*3.6/Validinput_DAREA
  k1 = 0.2
  k2 = 0.1
  out = GR4J(P,E,k1,k2,x1,x2,x3,x4)
  Rsi = out$RUNOFF
  R2 = 1-sum((Rre-Rsi)^2,na.rm = T)/sum((Rre-mean(Rre))^2,na.rm = T)
  return(1-R2)
}


paralower = c(50,-9,10,0.5)
paraupper = c(1500,9,500,5)
parainitial=c(500,1,200,2.1)
sceua_GR4J = sceua(fit, pars = parainitial, lower = paralower, 
                  upper = paraupper, maxn = 10000, pcento = 0.00001,iprint = 0)
para = sceua_GR4J$par
x1 = para[1]
x2 = para[2]
x3 = para[3]
x4 = para[4]
Rre = Validinput_Q*24*3.6/Validinput_DAREA
k1 = 0.2
k2 = 0.1
out = GR4J(P,E,k1,k2,x1,x2,x3,x4)
Rsi = out$RUNOFF
R2 = 1-sum((Rre-Rsi)^2,na.rm = T)/sum((Rre-mean(Rre))^2,na.rm = T)
R2
para
plot(1:length(Rsi),Rsi)
points(1:length(Rre),Rre, type = "l",col = "red")

