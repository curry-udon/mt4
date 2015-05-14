// Definition MAGIC Number YYYYMMDD
#define MAGIC 20150228

//---- input parameters
extern double Lots = 1;
extern int Slippage = 10;
extern int FastMA_Period = 10;
extern int SlowMA_Period = 25;
extern int ATR_Period =396;
extern double ATR_Multi = 5.0;
extern string Comments = "iMA ATR Trailing";

//-----Open Price Only--------
extern bool OpenPriceOnly = true;
int previousBar = -1;

double FastLine4 = 0;
double SlowLine4 = 0;
double FastLine3 = 0;
double SlowLine3 = 0;
double FastLine2 = 0;
double SlowLine2 = 0;
double FastLine1 = 0;
double SlowLine1 = 0;
double spread = 0;
double mATR = 0;
double TrailingStop_Short = 0;
double TrailingStop_Long = 0;

//-----Position Check Function----
int BUYpos,SELLpos;
void PosCheck(int magic)
{
    int buypos=0,sellpos=0;
    for(int i=OrdersTotal()-1; i>=0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS) == false) break;
        if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
        {
            if(OrderType() == OP_BUY )buypos++;
            if(OrderType() == OP_SELL)sellpos++;
        }              
    }
    BUYpos = buypos;
    SELLpos = sellpos;
    return(false);   
}

//-----ATR Trailing Function----
void  ClosedLC(int magic) 
{
   int ticket;
   for (int i = OrdersTotal() - 1; i >= 0; i--) 
   {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) 
      {
         if (OrderType() == OP_BUY)
         {
               if((NormalizeDouble(OrderStopLoss(),Digits)<NormalizeDouble( TrailingStop_Long ,Digits))||(OrderStopLoss()==0))
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble( TrailingStop_Long ,Digits),OrderTakeProfit(),0,Blue);
                  Print("Trailing Sell Stop");
               }
         }
         else if(OrderType() == OP_SELL)
         {
               if((NormalizeDouble(OrderStopLoss(),Digits)>(NormalizeDouble( TrailingStop_Short ,Digits)))||(OrderStopLoss()==0))
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble( TrailingStop_Short ,Digits),OrderTakeProfit(),0,Red);
                  Print("Trailing Buy Stop");
               }
         }
      }
   }
}      
        


int start()//--------------------------------------------------------------------------------
{
   //Loss Cut Order
   
   PosCheck(MAGIC);
   if(BUYpos>0||SELLpos>0)
   {
   spread = Ask - Bid;
   mATR = ATR_Multi * iATR(NULL, 0, ATR_Period, 1);
   TrailingStop_Short = High[1] + mATR + spread;
   TrailingStop_Long = Low[1] - mATR;   
   ClosedLC(MAGIC);
   }
   
   //Open Price Only
   if (OpenPriceOnly == true && previousBar == Bars) return (0);
   previousBar = Bars;
   
   //Line Setting----------------------------------------------------------------------------
   FastLine4 = iMA(NULL, 0, FastMA_Period, 0, MODE_SMA,PRICE_CLOSE, 4);
   SlowLine4 = iMA(NULL, 0, SlowMA_Period, 0, MODE_SMA,PRICE_CLOSE, 4);
   FastLine3 = iMA(NULL, 0, FastMA_Period, 0, MODE_SMA,PRICE_CLOSE, 3);
   SlowLine3 = iMA(NULL, 0, SlowMA_Period, 0, MODE_SMA,PRICE_CLOSE, 3);
   FastLine2 = iMA(NULL, 0, FastMA_Period, 0, MODE_SMA,PRICE_CLOSE, 2);
   SlowLine2 = iMA(NULL, 0, SlowMA_Period, 0, MODE_SMA,PRICE_CLOSE, 2);
   FastLine1 = iMA(NULL, 0, FastMA_Period, 0, MODE_SMA,PRICE_CLOSE, 1);
   SlowLine1 = iMA(NULL, 0, SlowMA_Period, 0, MODE_SMA,PRICE_CLOSE, 1);

   //Open Order------------------------------------------------------------------------------
   PosCheck(MAGIC);
   if(BUYpos!=0 || SELLpos!=0)return(0);
   
   /**/
   //Open Buy Position
   if((FastLine2 <= SlowLine2 && SlowLine1 < FastLine1 && SlowLine2 < SlowLine1 )
    || (FastLine3 <= SlowLine3 && SlowLine2 < FastLine2 && SlowLine3 >= SlowLine2 && SlowLine2 < SlowLine1)
    || (FastLine4 <= SlowLine4 && SlowLine3 < FastLine3 && SlowLine4 >= SlowLine3 && SlowLine3 >= SlowLine2 && SlowLine2 < SlowLine1)
    )
    {
      OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,0,Comments,MAGIC,0,Blue);
      Print("Buy Open Signal");
   }
 
   if(( SlowLine2 <= FastLine2 && FastLine1 < SlowLine1 && SlowLine2 > SlowLine1 )
    || (SlowLine3 <= FastLine3 && FastLine2 < SlowLine2 && SlowLine3 <= SlowLine2 && SlowLine2 > SlowLine1)
    || (SlowLine4 <= FastLine4 && FastLine3 < SlowLine3 && SlowLine4 <= SlowLine3 && SlowLine3 <= SlowLine2 && SlowLine2 > SlowLine1)
    )
   {
      OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,0,Comments,MAGIC,0,Red);
      Print("Sell Open Signal");
   }
return(0);
}