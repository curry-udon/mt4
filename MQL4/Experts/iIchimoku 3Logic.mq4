// マジックナンバーの定義
#define MAGIC 19191919

// パラメーターの設定//
extern int Tenkan = 9; // 転換線の期間設定
extern int Kijun = 26; // 基準線の期間設定
extern int Senkou = 52; // 先行線の期間設定

extern double Lots = 0.1;
extern int Slip = 10;
extern string Comments = " ";
extern int TP = 50;
extern int LC = 1500;
//新しいバーの開始時に処理を行う
extern bool OpenPriceOnly = false;
int previousBar = -1;

// 変数の設定//
int TicketL = 0; // 買い注文の結果をキャッチする変数
int TicketS = 0; // 売り注文の結果をキャッチする変数
int ExitL = 0; // 買いポジションの決済注文の結果をキャッチする変数
int ExitS = 0; // 売りポジションの決済注文の結果をキャッチする変数

double Chikou_2 = 0;
double Chikou_1 = 0;
double SenkouA_2 = 0;
double SenkouB_2 = 0;
double SenkouA_1 = 0;
double SenkouB_1 = 0;
double Tenkan2 = 0;
double Tenkan1 = 0;
double Kijun2 = 0;
double Kijun1 = 0;

//----new function------------------------------
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
//----new function------------------------------


int start()
{
//----new function------------------------------
   /*
	//ポジションのテイクプロフィット判定
   PosCheck(MAGIC);
   if(BUYpos>0||SELLpos>0)ClosedTP(MAGIC);  
   */
   
	//ポジションのロスカット判定
   PosCheck(MAGIC);
   if(BUYpos>0||SELLpos>0)ClosedLC(MAGIC);  
   
//----new function------------------------------

	//新しいバーの開始時に処理を行う
	if (OpenPriceOnly == true && previousBar == Bars) return (0);
	previousBar = Bars;

   Chikou_2 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,4,Kijun+1);
   Chikou_1 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,4,Kijun);
   SenkouA_2 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,5,2);
   SenkouB_2 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,6,2);
   SenkouA_1 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,5,1);
   SenkouB_1 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,6,1);
   Tenkan2 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,0,2);
   Kijun2 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,1,2);
   Tenkan1 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,0,1);
   Kijun1 = iCustom(NULL,0,"Ichimoku",Tenkan,Kijun,Senkou,1,1);



//---added-----------------------
   //ポジションチェック
   PosCheck(MAGIC);
//---added-----------------------

   //買いポジションの決済
   if(  ((SenkouA_2 <= Close[2] || SenkouB_2 <= Close[2]) && Chikou_2 >= Close[Kijun+1] && Tenkan2 >= Kijun2)
      &&  ((SenkouA_1 > Close[1] && SenkouB_1 > Close[1]) || Chikou_1 < Close[Kijun]  ||  Tenkan1 < Kijun1)
      && BUYpos>0//----------------
      )ClosedAll(MAGIC);//new--------

   //売りポジションの決済
   if( ((SenkouA_2 >= Close[2] || SenkouB_2 >= Close[2]) && Chikou_2 <= Close[Kijun+1] && Tenkan2 <= Kijun2)
      && ((SenkouA_1 < Close[1] && SenkouB_1 < Close[1]) || Chikou_1 > Close[Kijun] ||   Tenkan1 > Kijun1)
      && SELLpos>0//----------------
      )ClosedAll(MAGIC);//new-------
      
//----new function------------------------------  
   //ポジションチェック 
   PosCheck(MAGIC);
   if(BUYpos!=0 || SELLpos!=0)return(0);
//----new function------------------------------
   //買いポジションの新規
   if( (SenkouA_2 >= Close[2] || SenkouB_2 >= Close[2] || Chikou_2 <= Close[Kijun+1] ||   Tenkan2 <= Kijun2)
      && (SenkouA_1 < Close[1] && SenkouB_1 < Close[1] &&  Chikou_1 > Close[Kijun]  &&  Tenkan1 > Kijun1)
      )
      {
         OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);//new
      }
      
   // 売りエントリー
   if( (SenkouA_2 <= Close[2] || SenkouB_2 <= Close[2] || Chikou_2 >= Close[Kijun+1] || Tenkan2 >= Kijun2)
      && (SenkouA_1 > Close[1] && SenkouB_1 > Close[1] && Chikou_1 < Close[Kijun] &&   Tenkan1 < Kijun1)
      )
      {
         OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);//new
      }

   
return(0);
}