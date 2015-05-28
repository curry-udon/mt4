
// マジックナンバーの定義
#define MAGIC 3986

// パラメーターの設定//
extern int MA_Period=24;
extern int MA_Shift=0;
extern int MA_Method=0;
extern int Applied_Price=0;
extern double Deviation1=1.0;
extern double Deviation2=1.5;

extern double Lots = 0.1;
extern int Slip = 10;
extern string Comments = "Eagle1";
extern int TP = 50;
extern int LC = 3000;

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
	extern bool OpenPriceOnly = true;
	int previousBar = -1;

int start()
{
	/*
	//買いポジションの利益確定
	OrderSelect(TicketL, SELECT_BY_TICKET);

	if( OrderOpenPrice() + TP * Point <= Bid
	&& ( TicketL != 0 && TicketL != -1 ) )
	{ 
	ExitL = OrderClose(TicketL,Lots,Bid,Slip,Red);
	if( ExitL ==1 ) {TicketL = 0;}
	} 

	//売りポジションの利益確定
	OrderSelect(TicketS, SELECT_BY_TICKET);

	if( OrderOpenPrice() - TP * Point >= Ask
	&& ( TicketS != 0 && TicketS != -1 ) )
	{ 
	ExitS = OrderClose(TicketS,Lots,Ask,Slip,Blue);
	if( ExitS ==1 ) {TicketS = 0;}
	} 
	*/

	//買いポジションのロスカット
	OrderSelect(TicketL, SELECT_BY_TICKET);

	if( OrderOpenPrice() - LC * Point >= Bid
	&& ( TicketL != 0 && TicketL != -1 ) )
	{ 
	ExitL = OrderClose(TicketL,Lots,Bid,Slip,Red);
	if( ExitL ==1 ) {TicketL = 0;}
	} 

	//売りポジションのロスカット
	OrderSelect(TicketS, SELECT_BY_TICKET);

	if( OrderOpenPrice() + LC * Point <= Ask
	&& ( TicketS != 0 && TicketS != -1 ) )
	{ 
	ExitS = OrderClose(TicketS,Lots,Ask,Slip,Blue);
	if( ExitS ==1 ) {TicketS = 0;}
	} 

	//新しいバーの開始時に処理を行う
	if (OpenPriceOnly == true && previousBar == Bars) return (0);
	previousBar = Bars;



 OuterP2 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation2,0,2);
 OuterM2 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation2,1,2);
 InnerP2 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation1,0,2);
 InnerM2 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation1,1,2);
 OuterP1 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation2,0,1);
 OuterM1 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation2,1,1);
 InnerP1 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation1,0,1);
 InnerM1 = iCustom(NULL,0,"Envelopes",MA_Period,MA_Shift,MA_Method,Applied_Price,Deviation1,1,1);
 MA2 = iCustom(NULL,0,"Moving Averages",MA_Period,MA_Shift,MA_Method,0,2);
 MA1 = iCustom(NULL,0,"Moving Averages",MA_Period,MA_Shift,MA_Method,0,1);

   // 買いポジションのエグジット
   if(
       (( Close[2] <= MA2 &&  MA1 < Close[1] )
      ||( OuterM2 <= Close[2] && Close[1] < OuterM1 )) 
      && ( TicketL != 0 && TicketL != -1 )
     )
      {
         ExitL = OrderClose(TicketL,Lots,Bid,Slip,Blue);
         if( ExitL == 1 ) {TicketL = 0;}
      }
      
   // 売りポジションのエグジット
   if(
       (( MA2 <= Close[2] && Close[1] < MA1 )
      ||( Close[2] <= OuterP2 && OuterP1 < Close[1] )) 
      && ( TicketL != 0 && TicketL != -1 )
     )
      {
         ExitS = OrderClose(TicketS,Lots,Ask,Slip,Red);
         if( ExitS == 1 ) {TicketS = 0;}
      }
      
   // 買いエントリー
   if(    Close[2] <= InnerM2
      &&  InnerM1 < Close[1]
      &&  Close[1] <=  MA1
      && ( TicketL == 0 || TicketL == -1 )
      && ( TicketS == 0 || TicketS == -1 ))
      {
         TicketL = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0, Comments,MAGIC,0,Red);
      }
      
   // 売りエントリー
   if(    InnerP2 <= Close[2]
      &&  Close[1] < InnerP1
      &&  MA1 <= Close[1]
      && ( TicketS == 0 || TicketS == -1 )
      && ( TicketL == 0 || TicketL == -1 ))
      {
         TicketS = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);
      }
      
return(0);
}