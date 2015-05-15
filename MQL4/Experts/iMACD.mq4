#define MAGIC 5583


extern int FastEMAPeriod = 12;
extern int SlowEMAPeriod = 26;
extern int SignalPeriod = 9;

extern double Lots = 0.1;
extern int Slip = 10;
extern string Comments = " ";
extern int TP = 50;
extern int LC = 1500;
//新しいバーの開始時に処理を行う
extern bool OpenPriceOnly = true;
int previousBar = -1;

int TicketL = 0;
int TicketS = 0;
int ExitL = 0;
int ExitS = 0;

double FastMA2 = 0;
double SlowMA2 = 0;
double FastMA1 = 0;
double SlowMA1 = 0;

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

   FastMA2 = iCustom(NULL,0,"MACD",FastEMAPeriod,SlowEMAPeriod,SignalPeriod,0,2);
   SlowMA2 = iCustom(NULL,0,"MACD",FastEMAPeriod,SlowEMAPeriod,SignalPeriod,1,2);
   FastMA1 = iCustom(NULL,0,"MACD",FastEMAPeriod,SlowEMAPeriod,SignalPeriod,0,1);
   SlowMA1 = iCustom(NULL,0,"MACD",FastEMAPeriod,SlowEMAPeriod,SignalPeriod,1,1);

   if(   FastMA2 >= SlowMA2
      && FastMA1 < SlowMA1
      && ( TicketL != 0 && TicketL != -1 ))
      {
         ExitL = OrderClose(TicketL,Lots,Bid,Slip,Red);
         if( ExitL ==1 ) {TicketL = 0;}
      }
      
   if(   FastMA2 <= SlowMA2
      && FastMA1 > SlowMA1
      && ( TicketS != 0 && TicketS != -1 ))
      {
         ExitS = OrderClose(TicketS,Lots,Ask,Slip,Blue);
         if( ExitS ==1 ) {TicketS = 0;}
      }
      
   if(   FastMA2 <= SlowMA2
      && FastMA1 > SlowMA1
      && ( TicketL == 0 || TicketL == -1 )
      && ( TicketS == 0 || TicketS == -1 ))
      {
         TicketL = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
      }
      
   if(   FastMA2 >= SlowMA2
      && FastMA1 < SlowMA1
      && ( TicketS == 0 || TicketS == -1 )
      && ( TicketL == 0 || TicketL == -1 ))
      {
         TicketS = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);
      }
      
return(0);
}