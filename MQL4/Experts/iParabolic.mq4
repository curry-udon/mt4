// Definition MAGIC Number YYYYMMDD
#define MAGIC 20130627

extern double Lots = 0.1;
extern int Slip = 10;
extern int TP = 50;
extern int LC = 1500;

//-----Open Price Only--------
extern bool OpenPriceOnly = false;
int previousBar = -1;

//---- input parameters
extern string Comments = "Parabolic";
extern double    Step=0.02;
extern double    Maximum=0.2;
double SaR2 = 0;
double SaR1 = 0;

//-----Position Check Function----
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

//-----Close All Function----
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

/*-----Take Profit Function----
void  ClosedTP(int magic) {
   int ticket;
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if ((OrderType() == OP_BUY)&&(OrderOpenPrice() + TP * Point <= Bid)) 
         {
         ticket=OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Blue);
         Print("Taek Profit");
         }
         if ((OrderType() == OP_SELL)&&(OrderOpenPrice() - TP * Point >= Ask))
         {
         ticket=OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Red);
         Print("Take Profit");
         }
      }
   }
}
*/

//-----Loss Cut Function----
void  ClosedLC(int magic) {
   int ticket;
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if ((OrderType() == OP_BUY)&&(OrderOpenPrice() - LC * Point >= Bid))
         {
         ticket=OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Blue);
         Print("Loss Cut");
         }
         if ((OrderType() == OP_SELL)&&(OrderOpenPrice() + LC * Point <= Ask))
         {
         ticket=OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Red);
         Print("Loss Cut");
         }
      }
   }
}


int start()
{
   /*Take Profit Order
   PosCheck(MAGIC);
   if(BUYpos>0||SELLpos>0)ClosedTP(MAGIC);  
   */
   
	//Loss Cut Order
   PosCheck(MAGIC);
   if(BUYpos>0||SELLpos>0)ClosedLC(MAGIC);  
   
	//Open Price Only
	if (OpenPriceOnly == true && previousBar == Bars) return (0);
	previousBar = Bars;
	
	SaR2 = iSAR(NULL,0,Step,Maximum,2);
	SaR1 = iSAR(NULL,0,Step,Maximum,1);
 
   //Close Order----------------------------------------------
   PosCheck(MAGIC);

   //Close Buy Position
   if(    SaR2 <= Close[2]
      &&  Close[1] <  SaR1
      && BUYpos>0){
      Print("SaR2: ",SaR2, " <= Close[2]: ",Close[2]);
      Print("Close[1]: ", Close[1], " < SaR1: ",SaR1);
      ClosedAll(MAGIC);
   }
      
   //Close Sell Position
   if(    Close[2] <= SaR2
      &&  SaR1 <  Close[1]
      && SELLpos>0){
      Print("Close[2]: ",Close[2], " <= SaR2: ",SaR2);
      Print("SaR1: ", SaR1, " < Close[1]: ",Close[1]);
      ClosedAll(MAGIC);
   }

   //Open Order----------------------------------------------
   PosCheck(MAGIC);

   if(BUYpos!=0 || SELLpos!=0)return(0);
   /**/
   //Open Buy Position
   if(    Close[2] <= SaR2
      &&  SaR1 <  Close[1]){
      Print("Close[2]: ",Close[2], " <= SaR2: ",SaR2);
      Print("SaR1: ", SaR1, " < Close[1]: ",Close[1]);
      OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,Comments,MAGIC,0,Red);
   }
   /**/   
   //Open Sell Position
   if(    SaR2 <= Close[2]
      &&  Close[1] <  SaR1){
      Print("SaR2: ",SaR2, " <= Close[2]: ",Close[2]);
      Print("Close[1]: ", Close[1], " < SaR1: ",SaR1);
      OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,Comments,MAGIC,0,Blue);
   }
   /**/
return(0);
}