########################
#---------GR4J----------
########################

library(shiny)
library(rtop)
library(ggplot2)
library(ggthemes)
library(shinythemes)
library(RColorBrewer)
library(Cairo)   

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

paralower <<- c(50,-9,10,0.5)
paraupper <<- c(1500,9,500,5)
parainitial <<- c(500,1,200,2.1)

fit <- function(x) {
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

ui <- tagList(
  shinythemes::themeSelector(),
  navbarPage("GR4J",
             
             # ---------------Introduction------------------
             tabPanel("GR4J",
                      fluidRow(column(12,
                                      wellPanel(
                                        h3("GR4J前言",align = "center")       
                                      ))),
                      fluidRow(column(12,
                                      wellPanel(
                                        p("水文模型是对自然界复杂水循环过程的近似描述，
                                        通常可分为集总式水文模型和分布式水文模型。
一般而言，分布式水文模型对水文过程的考虑比较详细、物理机制相对完备，
但集总式模型具有结构简单、对基础资料要求相对较低等优点。
GR4J是一个概念性降雨径流模型，由法国人提出，
已经在法国、澳大利亚等400多个不同气候条件的流域得到验证。
GR4J模型具有四个参数，
且在模型原理和结构方面较同类模型具有一定特色。
GR4J模型采用两个线性水库进行产汇流计算。"),
                                        br(),
                                        p("Programmer:Shane Guan",align = "right"),
                                        p("E-mail:xxguan@hhu.edu.cn",align = "right")  
                                        
                                        ))),
                      p(em("Address:College of hydrology and water resources, Hohai University,1,Xikang Road,NanJing210098"),align = "center")
                      ),
             
             #--------------数据准备-----------------------
             tabPanel("数据准备",
                      sidebarLayout(
                        sidebarPanel(
                          h4("基本信息"),
                          textInput("Basinname","流域名:",
                                    value = ""),
                          numericInput("DAREA",
                                       "流域面积(km2):",
                                       step = 50,
                                       value = 4766),
                          fileInput("file", "选择数据文件",
                                    multiple = TRUE,
                                    accept = c("text/csv",
                                               "text/comma-separated-values,text/plain",
                                               ".csv")),
                          helpText("请选择本地数据文件;
                                   第一行留设为字段标题：年，月，日，时，降水(mm)，蒸发(mm)，观测流量(m3/s);
                                   或年，月，降水，蒸发，观测流量(m3/s)格式"),
                          #numericInput("DT1","计算时段(尺度)/h",value = 24,min = 1,max = 24,step =1)
                          selectInput("DT1","计算时段(尺度)",choices = c("Daily","Monthly"),selected = "Daily")
                          ),
                        mainPanel(
                          tabsetPanel(
                            tabPanel("数据列表",
                                     DT::dataTableOutput("datafile")
                            ),
                            tabPanel("数据图示", 
                                     
                                     plotOutput("precipitationplot",height = 300),
                                     hr(),
                                     plotOutput("dischargeplot",height = 300)
                            ),
                            tabPanel("数据统计", 
                                     h4("数据时限内月加总平均值统计表："),
                                     tableOutput("datastatistable")
                            )
                          )
                        )
                        )
             ),
             
             
             #----------模型率定------------------
             tabPanel("参数调试-Mannual",
                      fluidRow(
                        column(7,h3("模拟结果"),
                               wellPanel(
                                 
                                 h4(em("模拟与实测径流过程对比图:")),
                                 plotOutput("Simulatedplot",height = 300),
                                 hr(),
                                 h4(em("逐月月均流量过程:")),
                                 plotOutput("Q_monthly_plot",height = 300) 
                               )),
                        column(5,h3("模型参数"),
                               wellPanel(
                                 sliderInput("period", "Select simulation period", min = 1940, 
                                             max = 2020, value = c(1955, 1985),step = 1),
                                 fluidRow(
                                   column(4,
                                          wellPanel(
                                            numericInput("k1","初始产流水库含水量系数:",min = 0,value = 0.5,max = 1,step = 0.1),
                                            numericInput("k2","初始汇流水库含水量系数:",min = 0,value = 0.5,max = 1,step = 0.1)
                                          )
                                   ),
                                   column(4,
                                          wellPanel(
                                            numericInput("x1","产流水库容量x1/mm:",min = 0,value = 350,step = 10),
                                            helpText("100~1200"),
                                            numericInput("x3","汇流水库容量x3/mm",min = 0,value = 90,step = 5),
                                            helpText("20~300")
                                          )
                                   ),
                                   column(4,
                                          wellPanel(
                                            numericInput("x2","地下水交换系数x2:",min = -10,value = 0,step = 0.1),
                                            helpText("-5~3"),
                                            numericInput("x4","单位线汇流时间x4/d:",min = 0,value = 1.7,step = 0.1),
                                            helpText("1.1~2.9")
                                          )
                                   )
                                 ) 
                               ),
                               h4(em("模拟精度表:")),
                               tableOutput("Accuracy"),
                               fluidRow(
                                 column(6,
                                        wellPanel(
                                          selectInput("dataset_download", 
                                                      "选择下载数据集:",
                                                      choices = c("Runoff generation", 
                                                                  "Simulate & Record"))
                                          
                                        )
                                 ),
                                 column(6,
                                        wellPanel(
                                          downloadButton("downloadData","点击执行下载")
                                        )
                                 )
                               )
                               
                               
                        )
                      )      
             ),
             #--------待添加功能--------
             #----------模型率定------------------
             tabPanel("参数调试-SCEUA",
                      fluidRow(
                        column(7,h3("模拟结果"),
                               wellPanel(
                                 
                                 h4(em("模拟与实测径流过程对比图:")),
                                 plotOutput("Simulatedplot2",height = 300),
                                 hr(),
                                 h4(em("逐月月均流量过程:")),
                                 plotOutput("Q_monthly_plot2",height = 300) 
                               )),
                        column(5,h3("算法参数"),
                               wellPanel(
                                 sliderInput("period2", "Select simulation period", min = 1940, 
                                             max = 2030, value = c(1955, 1985),step = 1),
                                 fluidRow(
                                   column(6,
                                          wellPanel(
                                            numericInput("maxn","maxn:",min = 1,value = 2000, max = 50000,step = 100),
                                            
                                            helpText('the maximum number of function evaluations')
                                          )
                                   ),
                                   column(6,
                                          wellPanel(
                                            numericInput("pcento","pcento:",min = 0,value = 0.0001,max = 0.1,step = 0.0001),
                                            helpText('percentage by which the criterion value must change in given number (kstop) of shuffling loops to continue optimization')
                                          )
                                   )
                                   
                                   
                                 ),
                                 tags$br(),
                                 actionButton("SCEUA_run", "SCE-UA Go!",
                                              style = "background-color:#FA0505;
                                                       color:#FFFFFF;
                                                       border-color:#BEBEBE;
                                                       border-style:solid;
                                                       border-width:2px;
                                                       border-radius:100%;
                                                       font-size:18px;"),
                                 
                                 helpText("It may take some time, please be patient!"),
                                 verbatimTextOutput("nText")
                               ),
                               h4(em("SCEUA优化结果:")),
                               tableOutput("Accuracy2"),
                               tableOutput("Parameter2")

                               
                        )
                      )      
             )
             # tabPanel("NULL"
             #   
             # )
             
             )
  )


server <- function(input, output) {
  filedata <- reactive({
    req(input$file)
    df1 <- read.csv(input$file$datapath,
                    header = T,
                    sep = ",",
                    quote = '"')
    if (input$DT1 == "Daily") {
      `colnames<-`(df1,c("year","month","day","P","E","Q"))
    } else if(input$DT1 == "Monthly") {
      `colnames<-`(df1,c("year","month","P","E","Q"))
    }
  })
  output$datafile <- DT::renderDataTable({   
    df = filedata()
    
    DT::datatable(df)
  })
  output$precipitationplot <- renderPlot({
    dat = filedata()
    dat$x = 1:length(dat$year)
    ggplot(dat,aes(x,y = P,fill = P)) + geom_bar(stat = "identity")+
      xlab("Time")+ylab("Precipitation/mm")+theme(legend.position = "top")+
      theme(legend.title = element_blank())#+theme(guide_legend(direction = "horizontal"))
  })
  output$dischargeplot <- renderPlot({
    dat = filedata()
    dat$x = 1:length(dat[,1])
    ggplot(dat,aes(x,y = Q))+geom_line()+geom_area(alpha = 1/4)+
      xlab("Time")+
      ylab("Discharge/(m3/s)")+
      theme(legend.title = element_blank())
  })
  output$datastatistable <- renderTable({
    dat = filedata()
    monthly <- function(year,mon,value){
      out = NULL
      for (i in 1:12){
        out[i] = sum(value[mon == i],na.rm = T)/length(names(table(year)))
      }
      return(out) 
    }
    P_mon = monthly(dat$year, dat$month, dat$P)
    Q_mon = monthly(dat$year, dat$month, dat$Q)
    mon = 1:12
    out = data.frame(mon,P_mon,Q_mon)
    `colnames<-`(out,c("月份", "雨量/mm", "流量/(m3/s)"))
  })
  
  #---------------参数调试-manual----------------
  Simulate_raw <- reactive({

    dat = filedata()
    qi = input$period[1]
    zhi = input$period[2]
    dat = dat[dat[,1] >= qi & dat[,1] <= zhi,]
    
    out = GR4J(dat$P,dat$E,input$k1,input$k2,input$x1,input$x2,input$x3,input$x4)
    out
  })
  Simulate <- reactive({
    dat = Simulate_raw()  #P,E,Pn,RUNOFF
    rawdata = filedata()
    DAREA = input$DAREA
    
    qi = input$period[1]
    zhi = input$period[2]
    rawdata = rawdata[rawdata[,1] >= qi & rawdata[,1] <= zhi,]
    
    DT1 = input$DT1
    year = rawdata$year
    mon = rawdata$month
    if (DT1 == "Daily") {
      R_record = rawdata$Q * 3.6*24/DAREA
      qi_y = rawdata[1,1]
      zhi_y = rawdata[length(rawdata[,1]),1]
      YY = qi_y:zhi_y
      R_re = NULL
      R_si = NULL
      Year = NULL
      for (i in 1:length(YY)) {
        for (j in 1:12) {
          R_re[(i-1)*12+j] = sum(na.rm = T,R_record[year==YY[i] & mon == j])  #实测径流深，mm；月尺度
          R_si[(i-1)*12+j] = sum(na.rm = T,dat$RUNOFF[year==YY[i] & mon == j]) #模拟径流深，mm；月尺度
        }
        Year = c(Year,rep(YY[i],12))
      }
      Month = rep(1:12,length(YY))
      out = data.frame(Year,Month,R_re,R_si)
    } else if (DT1 == "Monthly") {
      R_re = rawdata$Q * 3.6*24/DAREA*30.4
      R_si = dat$RUNOFF
      out = data.frame(rawdata$year,rawdata$month,R_re,R_si)
    }
    out
  })
  #------------------Accuracy Table------------
  output$Accuracy <- renderTable({
    dat1 = Simulate_raw()  #P,E,Pn,RUNOFF
    rawdata = filedata()  #"year","month","day","hour","P","E","Q"
    qi = input$period[1]
    zhi = input$period[2]
    rawdata = rawdata[rawdata[,1] >= qi & rawdata[,1] <= zhi,]
    R_record = rawdata$Q * 3.6*24/(input$DAREA)  #mm
    R_simulate = dat1$RUNOFF  #mm
    
    R2 = NULL
    Re_runoff = NULL
    Re_discharge = NULL
    gap = NULL
    #***************日精度*********************    
    R2[1] = round(1-sum((R_record-R_simulate)^2,na.rm = T)/sum((R_record-mean(R_record))^2,na.rm = T),digits = 3)
    Re_runoff[1] = round(sum(R_simulate-R_record,na.rm = T)/sum(R_record,na.rm = T)*100,digits = 3) #径流深相对误差（%）
    Qm_si = max(R_simulate)
    Qm_re = max(R_record)
    Re_discharge[1] = round((Qm_si-Qm_re)/Qm_re*100,digits = 3) #洪峰流量相对误差（%）
    gap[1] = which.max(R_simulate) - which.max(R_record) #峰现时差
    
    dat = Simulate()      #"Qsimulated","Qrecorded"
    #**************月尺度精度统计*******************
    R2[2] = round(1-sum((dat$R_re-dat$R_si)^2,na.rm = T)/sum((dat$R_re-mean(dat$R_re))^2,na.rm = T),digits = 3)
    Re_runoff[2] = round(sum(dat$R_si-dat$R_re,na.rm = T)/sum(dat$R_re,na.rm = T)*100,digits = 3) #径流深相对误差（%）
    Qm_si = max(dat$R_si)
    Qm_re = max(dat$R_re)
    Re_discharge[2] = round((Qm_si-Qm_re)/Qm_re*100,digits = 3) #洪峰流量相对误差（%）
    gap[2] = which.max(dat$R_si)-which.max(dat$R_re) #峰现时差
    
    label = c("Daily","Monthly")
    out = data.frame(R2,Re_runoff,Re_discharge,gap)
    `colnames<-`(out,c("NSE","径流深相对误差/%","峰值相对误差/%","峰现时差"))
  })
  
  output$Simulatedplot <- renderPlot({

    dat = Simulate_raw()  #P,E,Pn,RUNOFF
    
    rawdata = filedata()
    qi = input$period[1]
    zhi = input$period[2]
    rawdata = rawdata[rawdata[,1] >= qi & rawdata[,1] <= zhi,]
    dat$R_si = dat$RUNOFF
    dat$R_re = rawdata$Q * 3.6*24/(input$DAREA)  #mm
    
    Q = c(dat$R_si,dat$R_re)
    x = rep(c(1:length(dat$R_si)),2)
    label = c(rep("Simulate",length(dat$R_si)),rep("Record",length(dat$R_re)))
    graph = data.frame(x,Q,label)
    ggplot(graph,aes(x = x,y = Q,linetype = label,colour = label))+geom_line(lwd = 0.8)+
      xlab("Time")+ylab("Runoff/(mm)") + theme(legend.position = "bottom")+
      guides(linetype = guide_legend(title = NULL),colour = guide_legend(title = NULL))+
      scale_color_brewer(palette = "Set1") 
  })
  output$Q_monthly_plot <- renderPlot({
    dat = Simulate()       #Qrs,Qri,Qrg,Qrt
    
    Q = c(dat$R_si,dat$R_re)
    x = rep(c(1:length(dat$R_si)),2)
    label = c(rep("Simulate",length(dat$R_si)),rep("Record",length(dat$R_re)))
    graph = data.frame(x,Q,label)
    ggplot(graph,aes(x = x,y = Q,linetype = label,colour = label))+geom_line(lwd = 0.8)+
      xlab("Time")+ylab("Runoff/(mm)") + theme(legend.position = "bottom")+
      guides(linetype = guide_legend(title = NULL),colour = guide_legend(title = NULL))+
      scale_color_brewer(palette = "Set1") 
  })
  #-------------data for download-------------
  datasetOutput <- reactive({
    Chanliu_Result = Simulate_raw()
    Simulation_Result = Simulate()
    
    switch(input$dataset_download,
           "Runoff generation" = Chanliu_Result,
           "Simulate & Record" = Simulation_Result)
  })  
  
  #----- Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(input$dataset_download,".csv", sep = "")
    },
    content = function(file) {
      write.csv(datasetOutput(), file, row.names = FALSE,
                quote = F)
    }
  )
  

  
  #---------------参数调试-SCEUA--------------
  #-------------------------------------------
  ntext <- eventReactive(input$SCEUA_run, {
    out = 'The iteration has ended, please check the results!'
    out
  })
  output$nText <- renderText({
    ntext()
  })
  
  sceuaText <- eventReactive(input$SCEUA_run, {
    dat = filedata()
    qi = input$period2[1]
    zhi = input$period2[2]
    dat = dat[dat[,1] >= qi & dat[,1] <= zhi,]
    Validinput_P <<- dat$P
    Validinput_E <<- dat$E
    Validinput_Q <<- dat$Q
    Validinput_DAREA <<- input$DAREA
    
    maxn = input$maxn
    pcento = input$pcento
    sceua_GR4J = sceua(fit, pars = parainitial, lower = paralower, 
                       upper = paraupper, maxn = 10000, pcento = 0.00001,iprint = 0)
    sceua_GR4J
  })
  
  Simulate_raw2 <- reactive({
    sceua_GR4J = sceuaText()
    para = sceua_GR4J$par
    x1 = para[1]
    x2 = para[2]
    x3 = para[3]
    x4 = para[4]
    
    dat = filedata()
    qi = input$period2[1]
    zhi = input$period2[2]
    dat = dat[dat[,1] >= qi & dat[,1] <= zhi,]
    
    out = GR4J(dat$P,dat$E,input$k1,input$k2,x1,x2,x3,x4)
    out
  })
  Simulate2 <- reactive({
    dat = Simulate_raw2()  #P,E,Pn,RUNOFF
    rawdata = filedata()
    DAREA = input$DAREA
    
    qi = input$period2[1]
    zhi = input$period2[2]
    rawdata = rawdata[rawdata[,1] >= qi & rawdata[,1] <= zhi,]
    
    DT1 = input$DT1
    year = rawdata$year
    mon = rawdata$month
    if (DT1 == "Daily") {
      R_record = rawdata$Q * 3.6*24/DAREA
      qi_y = rawdata[1,1]
      zhi_y = rawdata[length(rawdata[,1]),1]
      YY = qi_y:zhi_y
      R_re = NULL
      R_si = NULL
      Year = NULL
      for (i in 1:length(YY)) {
        for (j in 1:12) {
          R_re[(i-1)*12+j] = sum(na.rm = T,R_record[year==YY[i] & mon == j])  #实测径流深，mm；月尺度
          R_si[(i-1)*12+j] = sum(na.rm = T,dat$RUNOFF[year==YY[i] & mon == j]) #模拟径流深，mm；月尺度
        }
        Year = c(Year,rep(YY[i],12))
      }
      Month = rep(1:12,length(YY))
      out = data.frame(Year,Month,R_re,R_si)
    } else if (DT1 == "Monthly") {
      R_re = rawdata$Q * 3.6*24/DAREA*30.4
      R_si = dat$RUNOFF
      out = data.frame(rawdata$year,rawdata$month,R_re,R_si)
    }
    out
  })
  #------------------Accuracy Table------------
  output$Accuracy2 <- renderTable({
    dat1 = Simulate_raw2()  #P,E,Pn,RUNOFF
    rawdata = filedata()  #"year","month","day","hour","P","E","Q"
    qi = input$period2[1]
    zhi = input$period2[2]
    rawdata = rawdata[rawdata[,1] >= qi & rawdata[,1] <= zhi,]
    R_record = rawdata$Q * 3.6*24/(input$DAREA)  #mm
    R_simulate = dat1$RUNOFF  #mm
    
    R2 = NULL
    Re_runoff = NULL
    Re_discharge = NULL
    gap = NULL
    #***************日精度*********************    
    R2[1] = round(1-sum((R_record-R_simulate)^2,na.rm = T)/sum((R_record-mean(R_record))^2,na.rm = T),digits = 3)
    Re_runoff[1] = round(sum(R_simulate-R_record,na.rm = T)/sum(R_record,na.rm = T)*100,digits = 3) #径流深相对误差（%）
    Qm_si = max(R_simulate)
    Qm_re = max(R_record)
    Re_discharge[1] = round((Qm_si-Qm_re)/Qm_re*100,digits = 3) #洪峰流量相对误差（%）
    gap[1] = which.max(R_simulate) - which.max(R_record) #峰现时差
    
    dat = Simulate2()      #"Qsimulated","Qrecorded"
    #**************月尺度精度统计*******************
    R2[2] = round(1-sum((dat$R_re-dat$R_si)^2,na.rm = T)/sum((dat$R_re-mean(dat$R_re))^2,na.rm = T),digits = 3)
    Re_runoff[2] = round(sum(dat$R_si-dat$R_re,na.rm = T)/sum(dat$R_re,na.rm = T)*100,digits = 3) #径流深相对误差（%）
    Qm_si = max(dat$R_si)
    Qm_re = max(dat$R_re)
    Re_discharge[2] = round((Qm_si-Qm_re)/Qm_re*100,digits = 3) #洪峰流量相对误差（%）
    gap[2] = which.max(dat$R_si)-which.max(dat$R_re) #峰现时差
    
    label = c("Daily","Monthly")
    out = data.frame(R2,Re_runoff,Re_discharge,gap)
    `colnames<-`(out,c("NSE","径流深相对误差/%","峰值相对误差/%","峰现时差"))
  })
  
  output$Simulatedplot2 <- renderPlot({
    
    dat = Simulate_raw2()  #P,E,Pn,RUNOFF
    
    rawdata = filedata()
    qi = input$period2[1]
    zhi = input$period2[2]
    rawdata = rawdata[rawdata[,1] >= qi & rawdata[,1] <= zhi,]
    dat$R_si = dat$RUNOFF
    dat$R_re = rawdata$Q * 3.6*24/(input$DAREA)  #mm
    
    Q = c(dat$R_si,dat$R_re)
    x = rep(c(1:length(dat$R_si)),2)
    label = c(rep("Simulate2",length(dat$R_si)),rep("Record",length(dat$R_re)))
    graph = data.frame(x,Q,label)
    ggplot(graph,aes(x = x,y = Q,linetype = label,colour = label))+geom_line(lwd = 0.8)+
      xlab("Time")+ylab("Runoff/(mm)") + theme(legend.position = "bottom")+
      guides(linetype = guide_legend(title = NULL),colour = guide_legend(title = NULL))+
      scale_color_brewer(palette = "Set1") 
  })
  output$Q_monthly_plot2 <- renderPlot({
    dat = Simulate2()       #Qrs,Qri,Qrg,Qrt
    
    Q = c(dat$R_si,dat$R_re)
    x = rep(c(1:length(dat$R_si)),2)
    label = c(rep("Simulate",length(dat$R_si)),rep("Record",length(dat$R_re)))
    graph = data.frame(x,Q,label)
    ggplot(graph,aes(x = x,y = Q,linetype = label,colour = label))+geom_line(lwd = 0.8)+
      xlab("Time")+ylab("Runoff/(mm)") + theme(legend.position = "bottom")+
      guides(linetype = guide_legend(title = NULL),colour = guide_legend(title = NULL))+
      scale_color_brewer(palette = "Set1") 
  })
  output$Parameter2 <- renderTable({
    sceua_GR4J = sceuaText()
    para = sceua_GR4J$par
    x1 = para[1]
    x2 = para[2]
    x3 = para[3]
    x4 = para[4]
    out = data.frame(x1,x2,x3,x4)
    colnames(out) <- c('x1', 'x2', 'x3', 'x4')
    out
  })
}


# Run the application 
shinyApp(ui = ui, server = server)

