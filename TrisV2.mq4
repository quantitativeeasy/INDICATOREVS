//+------------------------------------------------------------------+
//|                                                   EA_Scalper.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "0.2.2"
#property strict

//---- indicator settings
#property  indicator_chart_window

#property description "Prima versione semifunzionante"

double repulseIndex7[4];
double repulseIndex12[4];
double repulseIndex13[4];
bool entrato = false; //Variabile che identifica lo stato del sistema (InTrade/NoTrade)
datetime entryTime;
int trade = 0; //0 - no trade, 1 - Long, 2 - Short

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
     

   //Print("Tempo = " , TimeCurrent());
   
   string text ="VANTAGGIOSLEALE";
   string name = "sendMail4";
   ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name,text, 18, "Corbel Bold", YellowGreen);
   ObjectSet(name, OBJPROP_CORNER, 0); // 0 = IN ALTO A SINISTRA
   ObjectSet(name, OBJPROP_XDISTANCE, 15);
   ObjectSet(name, OBJPROP_YDISTANCE, 10);
   
   
   
   string text1 ="Repulse Signal 1.0";
   
   string name1 = "InfoBar1";
   int WhichCorner=0;//0,1,2 or 3
   
   string sObjName="InfoBar1";
   ObjectCreate(sObjName, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(sObjName,text1, 18, "Corbel", White);
   ObjectSet(sObjName, OBJPROP_CORNER, WhichCorner);
   ObjectSet(sObjName, OBJPROP_XDISTANCE, 15);//left to right
   ObjectSet(sObjName, OBJPROP_YDISTANCE, 30);//top to bottom
    
   return(INIT_SUCCEEDED);
  }

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
      //Print("Tempo = " , TimeCurrent());
      
       
      for(int i=1;i<=3;i++) // Popolo i tre array con le ultime tre candele chiuse
      {
         repulseIndex7[i] =  NormalizeDouble((iCustom(Symbol(),0,  "RepulseCloseV",7,PRICE_CLOSE,2,i)),3);
         repulseIndex12[i] = NormalizeDouble(( iCustom(Symbol(),0,  "RepulseMedianV",12,PRICE_MEDIAN,2,i)),3);
         repulseIndex13[i] = NormalizeDouble((iCustom(Symbol(),0,  "RepulseMedianV",13,PRICE_MEDIAN,2,i)),3);
      }
      
      
      bool vadoLong12 =  ((repulseIndex12[2] <=  repulseIndex12[3]) && (repulseIndex12[2] <= repulseIndex12[1])); // Cambio colore perchè da short diventa long
      bool vadoShort12 =  ((repulseIndex12[2] >=  repulseIndex12[3]) && (repulseIndex12[2] >= repulseIndex12[1])); // Cambio colore perchè da short diventa long
      
      bool vadoLong13 =  ((repulseIndex13[2] <=  repulseIndex13[3]) && (repulseIndex13[2] <= repulseIndex13[1])); // Cambio colore perchè da short diventa long
      bool vadoShort13 =  ((repulseIndex13[2] >=  repulseIndex13[3]) && (repulseIndex13[2] >= repulseIndex13[1])); // Cambio colore perchè da short diventa long
      
      bool vadoLong7 =  (repulseIndex7[2] <= repulseIndex7[1] && repulseIndex7[1] > repulseIndex13[1]  && repulseIndex7[1] > repulseIndex12[1]); // Non c'è cambio colore 
      bool vadoShort7 =  (repulseIndex7[2] >= repulseIndex7[1] && repulseIndex7[1] < repulseIndex13[1] && repulseIndex7[1] < repulseIndex12[1]); // Non c'è cambio colore
      
      bool escoDaShort7 =  (trade == 2 && (repulseIndex7[2] <= repulseIndex7[1])); // Cambio colore perchè da short diventa long
      bool escoDaLong7 =  (trade == 1 && (repulseIndex7[2] >= repulseIndex7[1])); // Cambio colore perchè da Long diventa long
      
      Print("LONG12: " + vadoLong12 + " SHORT12: " + vadoShort12 + " LONG13: " + vadoLong13 + " SHORT13: " + vadoShort13 + " LONG7: " +vadoLong7 + " SHORT7: " + vadoShort7 + " Entrato: " + entrato); 
      Print("EscodaShort: " + escoDaShort7 + " escoDaLong: " + escoDaLong7 + " trade " + trade + " repulse2 "+ repulseIndex7[2] + " repulse1 " + repulseIndex7[1]);
      
      if(vadoLong12 && vadoLong13 && vadoLong7 && entrato == false && entryTime != Time[0])
      {
         Print("Cambio Colore ENTRA LONG");
    
         string   StrName = StringConcatenate("LONG",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS ));
         
         ObjectCreate (StrName,OBJ_ARROW_UP,0,Time[0],Low[0]);
         ObjectSetInteger(0,StrName,OBJPROP_WIDTH,4);
         ObjectSet (StrName,OBJPROP_COLOR,DeepSkyBlue);
         entrato = true;
         entryTime = Time[0];
         trade = 1;
         //Print("Valore di ritorno : ",vadoLong13, " Repulse 13 [1] [2] [3] ", repulseIndex13[2],"   " , repulseIndex13[3],"  " ,repulseIndex13[3]);
         //Print("Valore di ritorno : ",vadoLong12, " Repulse 12 [1] [2] [3] " ,repulseIndex12[2],"   " , repulseIndex12[3],"  " ,repulseIndex12[3]);
         //Print( "Valore di ritorno : ",vadoLong7, " Repulse 7 [1] [2] [3] " ,repulseIndex7[2],"   " , repulseIndex7[3],"  " ,repulseIndex7[3]);
     }
     else if(vadoShort12 && vadoShort13 && vadoShort7 && entrato == false && entryTime != Time[0] )
     {
         Print("Cambio Colore ENTRA SHORT");
        
         string   StrName = StringConcatenate("SHORT",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS ));     
    
         ObjectCreate (StrName,OBJ_ARROW_DOWN,0,Time[0],Low[0]);
         ObjectSetInteger(0,StrName,OBJPROP_WIDTH,4);
         ObjectSet (StrName,OBJPROP_COLOR,Red);
         entrato = true;
         entryTime = Time[0];
         trade = 2;
         
         //Print("Valore di ritorno : ",vadoLong13, " Repulse 13 [1] [2] [3] ", repulseIndex13[2],"   " , repulseIndex13[3],"  " ,repulseIndex13[3]);
         //Print("Valore di ritorno : ",vadoLong12, " Repulse 12 [1] [2] [3] " ,repulseIndex12[2],"   " , repulseIndex12[3],"  " ,repulseIndex12[3]);
         //Print( "Valore di ritorno : ",vadoLong7, " Repulse 7 [1] [2] [3] " ,repulseIndex7[2],"   " , repulseIndex7[3],"  " ,repulseIndex7[3]);
       
   }
   else
   {
   
   //Print(" non c'è Segnale ingresso ");
   
   //Print("Repulse 13 " , repulseIndex13[2],"   " , repulseIndex13[3],"  " ,repulseIndex13[3]);
   //Print("Repulse 12 " , repulseIndex12[2],"   " , repulseIndex12[3],"  " ,repulseIndex12[3]);
   //Print("Repulse 7 " , repulseIndex7[2],"   " , repulseIndex7[3],"  " ,repulseIndex7[3]);
    
   }
   if((escoDaShort7 || escoDaLong7) && entrato == true && entryTime != Time[0])
   {
        
     Print(" Segnale di uscita ");
      
     string   StrName = StringConcatenate("stop",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS ));     
 
     ObjectCreate (StrName,OBJ_TEXT,0,Time[0],Low[0]);
     ObjectSetText(StrName,"EXIT", 15, "Corbel Bold", White);
     // ObjectSetInteger(0,StrName,OBJPROP_WIDTH,10);
     //ObjectSet (StrName,OBJPROP_COLOR,clrAqua);
     //Print("Repulse 7 " , repulseIndex7[2],"   " , repulseIndex7[3],"  " ,repulseIndex7[3]);
     entrato = false;
     trade = 0;
   }

//--- return value of prev_calculated for next call
   return(rates_total);
//+------------------------------------------------------------------+
}


/*
bool  NuovaCandela() // True quando c'è una nuova candela al primo tick utile
{
  //  Print("Old time = " ,oldtime);
 
  if(oldtime != Time[0])
   {
      oldtime = Time[0];
      return true;
     }
   return false;

}*/