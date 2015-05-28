
// マジックナンバーの定義
#define MAGIC 3986

// パラメーターの設定//
extern int MA_Period=24;
extern int MA_Shift=0;
extern int MA_Method=0;
extern int Applied_Price=0;
extern double Deviation1=0.5;
extern double Deviation2=0.75;

extern double Lots = 0.1;
extern int Slip = 10;
extern string Comments = "Envelope1";
extern int TP = 50;
extern int LC = 1500;

// 変数の設定//
int TicketL = 0; // 買い注文の結果をキャッチする変数
int TicketS = 0; // 売り注文の結果をキャッチする変数
int ExitL = 0; // 買いポジションの決済注文の結果をキャッチする変数
int ExitS = 0; // 売りポジションの決済注文の結果をキャッチする変数


double OuterP2 = 0;
double OuterM2 = 0;
double InnerP2 = 0;
double InnerM2 = 0;
double OuterP1 = 0;
double OuterM1 = 0;
double InnerP1 = 0;
double InnerM1 = 0;
double MA2 =0;
double MA1 =0;

//新しいバーの開始時に処理を行う
	extern bool OpenPriceOnly = false;
	int previousBar = -1;

//----new function---------------
int BUYpos,SELLpos;
void PosCheck(int magic){
    int buypos=0,sellpos=0;
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
//ポジションのロスカット
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

//---added-----------------------
   /*
	//ポジションのテイクプロフィット判定
   PosCheck(MAGIC);
   if(BUYpos>0||SELLpos>0)ClosedTP(MAGIC);  
   */
   
	//ポジションのロスカット判定
   PosCheck(MAGIC);
   if(BUYpos>0||SELLpos>0)ClosedLC(MAGIC);  
   
//---added----------------------- 

	//新しいバーの開始時に処理を行う
	if (OpenPriceOnly == true && previousBar == Bars) return (0);
	previousBar = Bars;



 OuterP2 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation2,0,2);//-0.75
 OuterM2 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation2,1,2);//-0.75
 InnerP2 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation1,0,2);//-0.5
 InnerM2 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation1,1,2);
 OuterP1 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation2,0,1);
 OuterM1 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation2,1,1);
 InnerP1 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation1,0,1);
 InnerM1 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation1,1,1);
 MA2 = iMA(NULL,0,MA_Period,MA_Shift,MA_Method,0,2);
 MA1 = iMA(NULL,0,MA_Period,MA_Shift,MA_Method,0,1);


//---added-----------------------
   //クローズオーダー
   PosCheck(MAGIC);
//---added-----------------------


   // 買いポジションのエグジット
   if(
       (( MA2 <= Close[2] && Close[1] < MA1 ) ||( OuterM2 <= Close[2] && Close[1] < OuterM1 )) 
      && BUYpos>0//new
      )ClosedAll(MAGIC);//new
      
   // 売りポジションのエグジット
   if(
       (( Close[2] <= MA2 && MA1 < Close[1] )||( Close[2] <= OuterP2 && OuterP1 < Close[1] )) 
      && SELLpos>0//new
      )ClosedAll(MAGIC);//new


//---added-----------------------      
   //エントリーオーダー   
   PosCheck(MAGIC);
//---added-----------------------

   if(BUYpos!=0 || SELLpos!=0)return(0);//new

   // 買いエントリー
   if(    Close[2] <= InnerM2
      &&  InnerM1 < Close[1]
      &&  Close[1] <=  MA1
      )
      {
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
      }
      
   // 売りエントリー
   if(    InnerP2 <= Close[2]
      &&  Close[1] < InnerP1
      &&  MA1 <= Close[1]
      )
      {
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);
      }
      /**/
      
return(0);
}