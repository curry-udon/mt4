#define MAGIC 1192

extern double Lots = 0.1;
extern int Slip = 10;
extern string Comments = " ";
extern int TP = 50;
extern int LC = 1500;
//新しいバーの開始時に処理を行う
extern bool OpenPriceOnly = true;
int previousBar = -1;

int TicketL = 0; // 買い注文の結果をキャッチする変数
int TicketS = 0; // 売り注文の結果をキャッチする変数
int ExitL = 0; // 買いポジションの決済注文の結果をキャッチする変数
int ExitS = 0; // 売りポジションの決済注文の結果をキャッチする変数

double Heiken_Open_2 = 0; /*2 本前のバーの平均足の始値に変身した　　
　　　　　　　　　　　　　 iCustom 関数を代入する変数*/
double Heiken_Close_2 = 0; /*2 本前のバーの平均足の終値に変身した
　　　　　　　　　　　　　 iCustom 関数を代入する変数*/
double Heiken_Open_1 = 0; /*1 本前のバーの平均足の始値に変身した
　　　　　　　　　　　　　iCustom 関数を代入する変数*/
double Heiken_Close_1 = 0; /*1 本前のバーの平均足の終値に変身した
                          iCustom 関数を代入する変数*/


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

   Heiken_Open_2 = iCustom(NULL,0,"Heiken Ashi",0,2);
   Heiken_Close_2 = iCustom(NULL,0,"Heiken Ashi",3,2);
   Heiken_Open_1 = iCustom(NULL,0,"Heiken Ashi",0,1);
   Heiken_Close_1 = iCustom(NULL,0,"Heiken Ashi",3,1);
   
//---added-----------------------
   //クローズオーダー
   PosCheck(MAGIC);
//---added-----------------------

   // 買いポジションのエグジット
   if(   Heiken_Open_2 <= Heiken_Close_2
      && Heiken_Open_1 > Heiken_Close_1
      && BUYpos>0//new
      )ClosedAll(MAGIC);//new
      
   // 売りポジションのエグジット
   if(   Heiken_Open_2 >= Heiken_Close_2
      && Heiken_Open_1 < Heiken_Close_1
      && SELLpos>0//new
      )ClosedAll(MAGIC);//new


//---added-----------------------      
   //エントリーオーダー   
   PosCheck(MAGIC);
//---added-----------------------

   if(BUYpos!=0 || SELLpos!=0)return(0);//new


   // 買いエントリー
   if(   Heiken_Open_2 >= Heiken_Close_2
      && Heiken_Open_1 < Heiken_Close_1
      )
      {
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
      }
      
   // 売りエントリー
   if(   Heiken_Open_2 <= Heiken_Close_2
      && Heiken_Open_1 > Heiken_Close_1
      )
      {
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);
      }
      /**/
      
return(0);
}