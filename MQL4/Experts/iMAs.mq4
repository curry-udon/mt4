#define MAGIC 5582


extern int FastMAPeriod = 5;
extern int SlowMAPeriod = 25;
extern int MAShift = 0;
extern int MAMethod = 0;

extern double Lots = 0.1;
extern int Slip = 10;
extern string Comments = "Mouse";
extern int TP = 50;
extern int LC = 1500;
//新しいバーの開始時に処理を行う
extern bool OpenPriceOnly = true;
int previousBar = -1;

// 変数の設定//
int TicketL = 0;
int TicketS = 0;
int ExitL = 0;
int ExitS = 0;

double FastMA2 = 0;
double SlowMA2 = 0;
double FastMA1 = 0;
double SlowMA1 = 0;

//----terrace add---------------
int BUYpos,SELLpos;
void PosCheck(int magic){
    double buypos=0,sellpos=0;
    for(int i=OrdersTotal()-1; i>=0; i--){
        if(OrderSelect(i, SELECT_BY_POS) == false) break;
        if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic){
            if(OrderType() == OP_BUY )buypos++;
            if(OrderType() == OP_SELL)sellpos++;
        }              
    }
    BUYpos = buypos;
    SELLpos = sellpos;
    return(false);   
}
void  ClosedAll(int magic) {
   int ticket;
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if (OrderType() == OP_BUY)  ticket=OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Blue);
         if (OrderType() == OP_SELL) ticket=OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Red);
      }
   }
}

//----terrace---------------
/*
//ポジションのテイクプロフィット
void  ClosedTP(int magic) {
   int ticket;
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if ((OrderType() == OP_BUY)&&(OrderOpenPrice() + TP * Point <= Bid))  ticket=OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Blue);
         if ((OrderType() == OP_SELL)&&(OrderOpenPrice() - TP * Point >= Ask)) ticket=OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Red);
      }
   }
}
*/
//ポジションのロスカット関数
void  ClosedLC(int magic) {
   int ticket;
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if ((OrderType() == OP_BUY)&&(OrderOpenPrice() - LC * Point >= Bid))  ticket=OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Blue);
         if ((OrderType() == OP_SELL)&&(OrderOpenPrice() + LC * Point <= Ask)) ticket=OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Red);
      }
   }
}
//---added-----------------------

int start()
{
	//ポジションのロスカット処理
   PosCheck(MAGIC);
   if(BUYpos>0||SELLpos>0)ClosedLC(MAGIC);      

	//新しいバーの開始時に処理を行う
	if (OpenPriceOnly == true && previousBar == Bars) return (0);
	previousBar = Bars;

   FastLine2 = iMA(NULL, 0, MAPeriod1, 0, MODE_SMA,PRICE_CLOSE, 2);
   SlowLine2 = iMA(NULL, 0, MAPeriod2, 0, MODE_SMA,PRICE_CLOSE, 2);
   FastLine1 = iMA(NULL, 0, MAPeriod1, 0, MODE_SMA,PRICE_CLOSE, 1);
   SlowLine1 = iMA(NULL, 0, MAPeriod2, 0, MODE_SMA,PRICE_CLOSE, 1);


   //クローズオーダー
   PosCheck(MAGIC);
  
   if(   FastMA2 >= SlowMA2
      && FastMA1 < SlowMA1
      && BUYpos>0
      )ClosedAll(MAGIC);
      
   if(   FastMA2 <= SlowMA2
      && FastMA1 > SlowMA1
      && SELLpos>0
      )ClosedAll(MAGIC);
      
   //エントリーオーダー   
   PosCheck(MAGIC);
  
   if(BUYpos!=0 || SELLpos!=0)return(0);
   if(   FastMA2 <= SlowMA2
      && FastMA1 > SlowMA1)
      {
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
      }
      
   if(   FastMA2 >= SlowMA2
      && FastMA1 < SlowMA1)
      {
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);
      }
      
return(0);
}