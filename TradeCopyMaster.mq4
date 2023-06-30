//+------------------------------------------------------------------+
//|                                              TradeCopyMaster.mq4 |
//|                                                                  |
//| Copyright (c) 2023 metafx_trader
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011-2022, Syslog.eu, rel. 2022-06-22"
#property link      "http://syslog.eu"
input int id_server=11;
input int delay=1000;
int start,TickCount;
int Size=0,PrevSize=0;
int cnt1,TotalCounter;
string cmt;
string nl="\n";

int OrdId[],PrevOrdId[];
string OrdSym[],PrevOrdSym[];
int OrdTyp[],PrevOrdTyp[];
double OrdLot[],PrevOrdLot[];
double OrdPrice[],PrevOrdPrice[];
double OrdSL[],PrevOrdSL[];
double OrdTP[],PrevOrdTP[];


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()  {

  int handle=FileOpen("TradeCopy"+IntegerToString(id_server,3)+".csv",FILE_CSV|FILE_WRITE|FILE_COMMON,",");
  if(handle>0) {
    FileClose(handle);
  }else Print("File open has failed, error: ",GetLastError());
  
  return(0);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() {

  while(!IsStopped()) {
    start=GetTickCount();
    cmt=start+nl+"Counter: "+TotalCounter;
    get_positions();
    if(compare_positions()) save_positions();
    Comment(cmt);
    TickCount=GetTickCount()-start;
    if(delay>TickCount)Sleep(delay-TickCount-2);
  }
  Alert("end, TradeCopy EA stopped");
  Comment("");
  return(0);


//----

}


void get_positions() {
  Size=OrdersTotal();
  if (Size!= PrevSize) {
    ArrayResize(OrdId,Size);
    ArrayResize(OrdSym,Size);
    ArrayResize(OrdTyp,Size);
    ArrayResize(OrdLot,Size);
    ArrayResize(OrdPrice,Size);
    ArrayResize(OrdSL,Size);
    ArrayResize(OrdTP,Size);
  }

  for(int cnt=0;cnt<Size;cnt++) {
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
    OrdId[cnt]=OrderTicket();
    OrdSym[cnt]=OrderSymbol();
    OrdTyp[cnt]=OrderType();
    OrdLot[cnt]=OrderLots();
    OrdPrice[cnt]=OrderOpenPrice();
    OrdSL[cnt]=OrderStopLoss();
    OrdTP[cnt]=OrderTakeProfit();
  }  
  cmt=cmt+nl+"Size: "+Size;  
}   
   
bool compare_positions() {
  if (PrevSize != Size)return(true);
  for(int i=0;i<Size;i++) {
    if (PrevOrdSL[i]!=OrdSL[i])return(true);
    if (PrevOrdTP[i]!=OrdTP[i])return(true);
    if (PrevOrdPrice[i]!=OrdPrice[i])return(true);
    if (PrevOrdId[i]!=OrdId[i])return(true);
    if (PrevOrdSym[i]!=OrdSym[i])return(true);
    if (PrevOrdPrice[i]!=OrdPrice[i])return(true);
    if (PrevOrdLot[i]!=OrdLot[i])return(true);
    if (PrevOrdTyp[i]!=OrdTyp[i])return(true);
  }    
  return(false);
}

void save_positions() {

  if (PrevSize != Size) {
    ArrayResize(PrevOrdId,Size);
    ArrayResize(PrevOrdSym,Size);
    ArrayResize(PrevOrdTyp,Size);
    ArrayResize(PrevOrdLot,Size);
    ArrayResize(PrevOrdPrice,Size);
    ArrayResize(PrevOrdSL,Size);
    ArrayResize(PrevOrdTP,Size);
    PrevSize=Size;
  }
  
  
  for(int i=0;i<Size;i++) {
    PrevOrdId[i]=OrdId[i];
    PrevOrdSym[i]=OrdSym[i];
    PrevOrdTyp[i]=OrdTyp[i];
    PrevOrdLot[i]=OrdLot[i];
    PrevOrdPrice[i]=OrdPrice[i];
    PrevOrdSL[i]=OrdSL[i];
    PrevOrdTP[i]=OrdTP[i];
  }


  int handle=FileOpen("TradeCopy"+IntegerToString(id_server,3)+".csv",FILE_CSV|FILE_WRITE|FILE_COMMON,",");
  if(handle>0) {
    FileWrite(handle,TotalCounter);
    TotalCounter++;
    for(i=0;i<Size;i++) {
      FileWrite(handle,OrdId[i],OrdSym[i],OrdTyp[i],OrdLot[i],OrdPrice[i],OrdSL[i],OrdTP[i]);
    }
    FileClose(handle);
  }else Print("File open has failed, error: ",GetLastError());
}

   
//+------------------------------------------------------------------+
