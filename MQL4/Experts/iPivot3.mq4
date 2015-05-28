
// マジックナンバーの定義
#define MAGIC 3986

// パラメーターの設定//


extern double Lots = 0.1;
extern int Slip = 10;
extern string Comments = "Eagle1";
extern int TP = 50;
extern int LC = 1500;

// 変数の設定//
int TicketL = 0; // 買い注文の結果をキャッチする変数
int TicketS = 0; // 売り注文の結果をキャッチする変数
int ExitL = 0; // 買いポジションの決済注文の結果をキャッチする変数
int ExitS = 0; // 売りポジションの決済注文の結果をキャッチする変数

double PP_2 = 0;
double S1_2 = 0;
double R1_2 = 0;
double S2_2 = 0;
double R2_2 = 0;
double S3_2 = 0;
double R3_2 = 0;
double PP_1 = 0;
double S1_1 = 0;
double R1_1 = 0;
double S2_1 = 0;
double R2_1 = 0;
double S3_1 = 0;
double R3_1 = 0;

//新しいバーの開始時に処理を行う
	extern bool OpenPriceOnly = true;
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

 PP_2 = iCustom(NULL,0,"Pivot_v1",0,2);
 R1_2 = iCustom(NULL,0,"Pivot_v1",1,2);
 S1_2 = iCustom(NULL,0,"Pivot_v1",2,2);
 R2_2 = iCustom(NULL,0,"Pivot_v1",3,2);
 S2_2 = iCustom(NULL,0,"Pivot_v1",4,2);
 R3_2 = iCustom(NULL,0,"Pivot_v1",5,2);
 S3_2 = iCustom(NULL,0,"Pivot_v1",6,2);

 PP_1 = iCustom(NULL,0,"Pivot_v1",0,1);
 R1_1 = iCustom(NULL,0,"Pivot_v1",1,1);
 S1_1 = iCustom(NULL,0,"Pivot_v1",2,1);
 R2_1 = iCustom(NULL,0,"Pivot_v1",3,1);
 S2_1 = iCustom(NULL,0,"Pivot_v1",4,1);
 R3_1 = iCustom(NULL,0,"Pivot_v1",5,1);
 S3_1 = iCustom(NULL,0,"Pivot_v1",6,1);


//---added-----------------------
   //クローズオーダー
   PosCheck(MAGIC);
//---added-----------------------

   // 買いポジションのエグジット
   if(( (PP_2 <= Close[2] &&  Close[1] <  PP_1) 
      ||(R1_2 <= Close[2] &&  Close[1] <  R1_1) 
      ||(R2_2 <= Close[2] &&  Close[1] <  R2_1)
      ||( PP_2 <= Close[1] &&  Close[0] <  PP_1) )
      && BUYpos>0//new
      )ClosedAll(MAGIC);//new
      
   // 売りポジションのエグジット
   if(( (Close[2] <= PP_2 &&  PP_1 < Close[1])  
      ||(Close[2] <= S1_2 &&  S1_1 < Close[1])  
      ||(Close[2] <= S2_2 &&  S2_1 < Close[1]) 
      ||( Close[1] <= PP_2  &&  PP_1 < Open[0])  )
      && SELLpos>0//new
      )ClosedAll(MAGIC);//new

//---added-----------------------      
   //エントリーオーダー   
   PosCheck(MAGIC);
//---added-----------------------

   if(BUYpos!=0 || SELLpos!=0)return(0);//new

      

   // 買いエントリー
   if(    Close[1] <= PP_2  &&  PP_1 < Open[0]
      )
      {
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Blue);
      }
      
   // 売りエントリー
   if(        PP_2 <= Close[1] &&  Close[0] <  PP_1
      )
      {
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Red);
      }
      /**/
      
return(0);
}