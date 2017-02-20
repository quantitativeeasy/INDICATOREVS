//+------------------------------------------------------------------+
//|                                                    RepulseT3.mq4 |
//|                                                        Savoiardo |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Savoiardo"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_width1 2
#property indicator_width2 2
#property indicator_style1 DRAW_LINE
#property indicator_style2 DRAW_LINE
#property indicator_color1 Lime
#property indicator_color2 Red


input int period=22;

double lo;
double hi;
double a[];
double b[];
double d[];
double repulseL[];
double repulseS[];

double medianPrice;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,repulseL,INDICATOR_DATA);
   SetIndexBuffer(1,repulseS,INDICATOR_DATA);
   SetIndexBuffer(3,a,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,b,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,d,INDICATOR_DATA);

   IndicatorShortName("Repulse Close ("+IntegerToString(period)+")");

   SetIndexLabel(0,"Repulse Long");
   SetIndexLabel(1,"Repulse Short");
   //SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
   SetIndexLabel(4,NULL);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_NONE);

   ArraySetAsSeries(repulseL,true);
   ArraySetAsSeries(repulseS,true);
   ArraySetAsSeries(a,true);
   ArraySetAsSeries(b,true);
   ArraySetAsSeries(d,true);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int startFrom;
   if(prev_calculated==0)
     {
      startFrom=rates_total-period-1;
     }
   else
     {
      startFrom=0;
     }

   for(int i=startFrom;i>=0 && !IsStopped();i--)
   {
      medianPrice=(High[i]+Low[i])/2;
      lo = Low[iLowest(Symbol(),Period(),MODE_LOW,period,i)];
      hi = High[iHighest(Symbol(),Period(),MODE_HIGH,period,i)];
      a[i] = 100*(3*medianPrice-2*lo-Open[period-1+i])/medianPrice;
      b[i] = 100*(Open[period-1+i]+2*hi-3*medianPrice)/medianPrice;
      d[i] = 500*(iMAOnArray(a,0,5*period,0,MODE_EMA,i)-iMAOnArray(b,0,5*period,0,MODE_EMA,i));
  
      if(d[i]>d[i+1])
        {
         repulseL[i]=d[i];
         repulseL[i+1]=d[i+1];
         repulseS[i]=EMPTY_VALUE;
        }
      else if(d[i]<d[i+1])
        {
         repulseS[i]=d[i];
         repulseS[i+1]=d[i+1];
         repulseL[i]=EMPTY_VALUE;
        }
      else if(d[i]==d[i+1])
        {
         if(repulseL[i+1]!=EMPTY_VALUE)
           {
            repulseL[i]=d[i];
            repulseS[i]=EMPTY_VALUE;
           }
         else if(repulseS[i+1]!=EMPTY_VALUE)
           {
            repulseL[i]=EMPTY_VALUE;
            repulseS[i]=d[i];
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
