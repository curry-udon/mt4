#define MAGIC 5583

//---- input parameters
extern int parameter1 = 24;
extern int parameter2 = 48;
extern int parameter3 = 96;

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

double FastLine2 = 0;
double SlowLine2 = 0;
double FastLine1 = 0;
double SlowLine1 = 0;

int start()
{
	/*
	//買いポジションの利益確定
	OrderSelect(TicketL, SELECT_BY_TICKET);

	if( OrderOpenPrice() + TP * Point <= Bid
	&& ( TicketL != 0 && TicketL != -1 ) )
	{ 
	ExitL = OrderClose(TicketL,Lots,Bid,Slip,Blue);
	if( ExitL ==1 ) {TicketL = 0;}
	} 

	//売りポジションの利益確定
	OrderSelect(TicketS, SELECT_BY_TICKET);

	if( OrderOpenPrice() - TP * Point >= Ask
	&& ( TicketS != 0 && TicketS != -1 ) )
	{ 
	ExitS = OrderClose(TicketS,Lots,Ask,Slip,Red);
	if( ExitS ==1 ) {TicketS = 0;}
	} 
	*/

	//買いポジションのロスカット
	OrderSelect(TicketL, SELECT_BY_TICKET);

	if( OrderOpenPrice() - LC * Point >= Bid
	&& ( TicketL != 0 && TicketL != -1 ) )
	{ 
	ExitL = OrderClose(TicketL,Lots,Bid,Slip,Blue);
	if( ExitL ==1 ) {TicketL = 0;}
	} 

	//売りポジションのロスカット
	OrderSelect(TicketS, SELECT_BY_TICKET);

	if( OrderOpenPrice() + LC * Point <= Ask
	&& ( TicketS != 0 && TicketS != -1 ) )
	{ 
	ExitS = OrderClose(TicketS,Lots,Ask,Slip,Red);
	if( ExitS ==1 ) {TicketS = 0;}
	} 

	//新しいバーの開始時に処理を行う
	if (OpenPriceOnly == true && previousBar == Bars) return (0);
	previousBar = Bars;

   FastLine2 = iCustom(NULL,0,"RCI",parameter1,parameter2,parameter3,1,2);
   SlowLine2 = iCustom(NULL,0,"RCI",parameter1,parameter2,parameter3,0,2);
   FastLine1 = iCustom(NULL,0,"RCI",parameter1,parameter2,parameter3,1,1);
   SlowLine1 = iCustom(NULL,0,"RCI",parameter1,parameter2,parameter3,0,1);

   if(   SlowLine2 <= FastLine2
      && FastLine1 < SlowLine1
      && ( TicketL != 0 && TicketL != -1 ))
      {
         ExitL = OrderClose(TicketL,Lots,Bid,Slip,Blue);
         if( ExitL ==1 ) {TicketL = 0;}
      }
      
   if(   FastLine2 <= SlowLine2
      && SlowLine1 < FastLine1
      && ( TicketS != 0 && TicketS != -1 ))
      {
         ExitS = OrderClose(TicketS,Lots,Ask,Slip,Red);
         if( ExitS ==1 ) {TicketS = 0;}
      }
      
   if(   FastLine2 <= SlowLine2
      && SlowLine1 < FastLine1
      && ( TicketL == 0 || TicketL == -1 )
      && ( TicketS == 0 || TicketS == -1 ))
      {
         TicketL = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
      }
      
   if(   SlowLine2 <= FastLine2
      && FastLine1 < SlowLine1
      && ( TicketS == 0 || TicketS == -1 )
      && ( TicketL == 0 || TicketL == -1 ))
      {
         TicketS = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);
      }
      
return(0);
}