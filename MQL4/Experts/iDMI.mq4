
// マジックナンバーの定義
#define MAGIC 3986

// パラメーターの設定//
extern int parameter1=240; //ADXPeriod=240

extern double Lots = 0.1;
extern int Slip = 10;
extern string Comments = "ADX";
extern int TP = 50;
extern int LC = 1500;

// 変数の設定//
int TicketL = 0; // 買い注文の結果をキャッチする変数
int TicketS = 0; // 売り注文の結果をキャッチする変数
int ExitL = 0; // 買いポジションの決済注文の結果をキャッチする変数
int ExitS = 0; // 売りポジションの決済注文の結果をキャッチする変数


double pDI2 = 0;
double mDI2 = 0;
double pDI1 = 0;
double mDI1 = 0;


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


 pDI2 = iCustom(NULL,0,"ADX",parameter1,1,2);
 mDI2 = iCustom(NULL,0,"ADX",parameter1,2,2);
 pDI1 = iCustom(NULL,0,"ADX",parameter1,1,1);
 mDI1 = iCustom(NULL,0,"ADX",parameter1,2,1);

//---added-----------------------
   //クローズオーダー
   PosCheck(MAGIC);
//---added-----------------------

   // 買いポジションのエグジット
   if(    mDI2 <= pDI2
      &&  pDI1 <  mDI1
      && BUYpos>0//new
      )ClosedAll(MAGIC);//new
      
   // 売りポジションのエグジット
   if(    pDI2 <= mDI2
      &&  mDI1 <  pDI1
      && SELLpos>0//new
      )ClosedAll(MAGIC);//new

//---added-----------------------      
   //エントリーオーダー   
   PosCheck(MAGIC);
//---added-----------------------

   if(BUYpos!=0 || SELLpos!=0)return(0);//new

      
      
   // 買いエントリー
   if(    pDI2 <= mDI2
      &&  mDI1 <  pDI1
      )
      {
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
      }
      
   // 売りエントリー
   if(    mDI2 <= pDI2
      &&  pDI1 <  mDI1
      )
      {
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);
      }
      /**/
      
return(0);
}